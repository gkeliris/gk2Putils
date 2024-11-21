function parameters = gk_plot_tuning(xpr, cellNum, grp, stimValues, xlabelStr,force_recalc,fitChoice)
% USAGE: [parameters] = gk_plot_tuning(xpr, cellNum, grp, stimValues, [xlabelStr],[force_recalc],[fit_type])
%
% Function that plots the tuning function of roi/neuron
%
% Input: xpr - a structure returned by gk_exp_getSigTrials/gk_getTunedROIs
%        cellNum - the number of the cell (not global ROI) in xpr
%        grp - the group number
%        stimValues - the type of stimuli stored in xpr.stimValues
%        xlabelStr - a string to label the x axis (optional)
%        force_recalc - recalculate fit even if it is already in xpr
%
%        fitChoice - 'mean': fits the means for each stimValue [default]
%                    'wgt' : fit the mean's weighted by 1/std^2
%                    'all' : fit all the trials
%
% Output: parameters - the fitting parameters [optional]
%
% See also FitNakaRushton, ComputeNakaRushton

% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022
% v2.0 - 19 Aug 2024
% v3.0 - 15 Nov 2024

if nargin < 7; fitChoice = 'mean'; end
if nargin < 6; force_recalc = false; end
if nargin < 5; xlabelStr = 'stimulus parameter'; end
tunedCellID = find(xpr.onTunedIDs_allGrp==cellNum);
%% READ THE DATA
stim.Values=stimValues';
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

%% PLOT THE DATA POINTS
if strcmp(fitChoice,'all')
    plot(stim.ValuesNtrials,sig.Trials','o','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[0.75 0.75 0.75]);
end
yline([0],'--'); hold on;
errorbar(stim.Values,sig.Mean,sig.Sem,'ko','MarkerFaceColor',[0 0 0]);
xlabel(xlabelStr);
ylabel('\DeltaF/F');
title(['CELL#: ' num2str(cellNum) ', ROI#: ' num2str(xpr.cellIDs(cellNum))]);
%% GET THE MODEL FIT PARAMETERS FOR DIFFERENT EXP TYPES
switch xpr.expType
    case 'contrast'
        if ~isfield(xpr,'tuning_params') || force_recalc     %calculate fit
            prm=fit_contrast(stim,sig,fitChoice);
        else
            prm=xpr.tuning_params{tunedCellID, grp};
        end
        xlim([-1 101]);
    case 'OR'
        if ~isfield(xpr,'tuning_params')  || force_recalc    %calculate fit
            prm=fit_OR(stim,sig,fitChoice);
        else
            prm=xpr.tuning_params{tunedCellID};
        end
        xlim([-5 175]);
    case 'DR'
        if ~isfield(xpr,'tuning_params')  || force_recalc    %calculate fit
            prm=fit_DR(stim,sig,fitChoice);
        else
            prm=xpr.tuning_params{tunedCellID};
        end
        xlim([-5 355]);
    case 'OO'
        % code for OO tuning
    case 'SF'
        % code for SF tuning
    case 'TF'
        % code for TF tuning
    otherwise
        error('Unknown experiment type');
end
%% PLOT
plot(prm.f,'r'); ax=gca; ax.Children(1).LineWidth=2; legend off;
xlabel(xlabelStr);
ylabel('\DeltaF/F');
%% OUTPUT (if requested)
if nargout > 0
    parameters=prm;
end

return