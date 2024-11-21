function xpr = gk_calc_tuning(xpr, fitChoice)
% USAGE: xpr = gk_calc_tuning(xpr, [fitChoice])
%
% Function that calculates the tuning functions of the rois/neurons
%
% Input: xpr - a structure returned by gk_exp_getSigTrials/gk_getTunedROIs
%
%        fitChoice - 'mean': fits the means for each stimValue [default]
%                    'wgt' : fit the mean's weighted by 1/std^2
%                    'all' : fit all the trials
%
% Output: xpr + including the fitting parameters in xpr.

% Author: Georgios A. Keliris (modified gk_plot_tuning)
% v1.0 - 13 Nov 2024
if nargin <2; fitChoice = 'mean'; end
if numel(xpr.onTunedIDs_allGrp)==0
    fprintf('No tuned cells found for this dataset\n')
    return
end
h = waitbar(0, 'Fitting cells...');
for c = 1:numel(xpr.onTunedIDs_allGrp)
    cellNum = xpr.onTunedIDs_allGrp(c);
    waitbar(c/numel(xpr.tunedGlobalIDs),h,sprintf('Fitting (neuron: %d/%d)',c,numel(xpr.tunedGlobalIDs)));
    for grp = 1:numel(xpr.grp)
        
        %% READ THE DATA
        stim.Values=xpr.stimValues';
        sig.Mean = cellfun(@(x) squeeze(mean(x(cellNum,:),2)),xpr.sorted_trials_ONresp,'UniformOutput',false);
        sig.Mean = [sig.Mean{:,grp}];
        sig.Trials = cellfun(@(x) x(cellNum,:),xpr.sorted_trials_ONresp,'UniformOutput',false);
        sig.Std = cellfun(@(x) squeeze(std(x(cellNum,:),0,2)),xpr.sorted_trials_ONresp,'UniformOutput',false);
        sig.Std = [sig.Std{:,grp}];
        sig.Sem = cellfun(@(x) squeeze(std(x(cellNum,:),0,2)./sqrt(size(x,2))),xpr.sorted_trials_ONresp,'UniformOutput',false);
        sig.Sem = [sig.Sem{:,grp}];
        Ntrials = cellfun(@(x) length(x),sig.Trials,'UniformOutput',false);
        Ntrials = [Ntrials{:,grp}]; sig.Trials = [sig.Trials{:,grp}];
        stim.ValuesNtrials = [];
        for i=1:length(stim.Values)
            stim.ValuesNtrials = [stim.ValuesNtrials repmat(stim.Values(i),1,Ntrials(i))];
        end
        %% CALCULATE THE MODEL FIT PARAMETERS FOR DIFFERENT EXP TYPES  
        switch xpr.expType
            
            case 'contrast'
            
                xpr.tuning_params{c,grp}=fit_contrast(stim,sig,fitChoice);
                
            case 'OR'
                
                xpr.tuning_params{c}=fit_OR(stim,sig,fitChoice);
                
            case 'DR'
                
                xpr.tuning_params{c}=fit_DR(stim,sig,fitChoice);
                
            case 'OO'
                % code for OO tuning
            case 'SF'
                % code for SF tuning
            case 'TF'
                % code for TF tuning
            otherwise
                error('Unknown experiment type');
        end
    end
end
waitbar(c/numel(xpr.tunedGlobalIDs),h,sprintf('Sorting cells... Please wait'));
xpr = gk_sortFit(xpr);
waitbar(c/numel(xpr.tunedGlobalIDs),h,sprintf('Saving... Please wait'));
try 
    save(fullfile(setSesPath(xpr.ds),'matlabana',xpr.saveFilename),'xpr')
catch
    save('xpr.mat','xpr')
end
delete(h)
return