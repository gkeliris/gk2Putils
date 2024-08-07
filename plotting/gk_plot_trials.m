function gk_plot_trials(xpr, cellNum, grp, stimValues, plotShadedSEM)
% USAGE: gk_plot_trials(xpr, cellNum, grp, stimValues, [plotShadedSEM=false])
%
% Function that plots the time courses for different stimulus types
%
% Input: xpr - a structure returned by gk_exp_getSigTrials/gk_getTunedROIs
%        cellNum - the number of the cell (not global ROI) in xpr
%        grp - the group number
%        stimValues - the type of stimuli stored in stim.Values
%        plotShadedSEM - if true will plot SEM (shaded)
%
% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022 


if nargin == 4
    plotShadedSEM = false;
end

sigMean = cellfun(@(x) squeeze(mean(x(cellNum,:,:),3)'),xpr.sorted_trials_dF_F,'UniformOutput',false);
sigMean = [sigMean{:,grp}];
p = plot(xpr.t,sigMean);

if plotShadedSEM
    %Ntrials = size(sig.trials,3);
    % = cellfun(@(x) size(x,3),sig.sorted_trials_dF_F,'UniformOutput',false);

    %sigSEM  = squeeze(std(sig.trials_dF_F(roiNum,:,:),0,3)./sqrt(Ntrials));
    sigSEM = cellfun(@(x) squeeze(std(x(cellNum,:,:),0,3)'./sqrt(size(x,3))),xpr.sorted_trials_dF_F,'UniformOutput',false);
    sigSEM = [sigSEM{:,grp}];
    if numel(stimValues)==1
        shadedErrorBar(xpr.t,sigMean,sigSEM,...
            'lineprops',{'Color', p(1).Color}, 'transparent', 1);
    else
        for tr=1:numel(stimValues)
            shadedErrorBar(xpr.t,sigMean(:,tr),sigSEM(:,tr),...
                'lineprops',{'Color', p(tr).Color}, 'transparent', 1);
        end
    end
    clear p
end

%xline([0 sig.stim_dur],':',{'stim ON', 'stim OFF'});
xline(0,':','stim ON');
xline(xpr.stim_dur,':','stim OFF');
xlabel('time [s]')
ylabel('\DeltaF/F')
legend(num2str(stimValues),'Location','northwest');
title(['CELL#: ' num2str(cellNum) ', ROI#: ' num2str(xpr.cellIDs(cellNum))]);

return