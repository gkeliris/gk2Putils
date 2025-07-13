function gk_plot_trials(xpr, cellNum, grp, stimValues, plotShadedSEM, labels_on)
% USAGE: gk_plot_trials(xpr, cellNum, [grp=1], [stimValues=xpr.stimValues], [plotShadedSEM=false], [labels_on=true])
%
% Function that plots the time courses for different stimulus types
%
% Input: xpr - a structure returned by gk_exp_getSigTrials/gk_getTunedROIs
%        cellNum - the number of the cell (not global ROI) in xpr
%        grp - the group number
%        stimValues - the type of stimuli stored in stim.Values
%        plotShadedSEM - if true will plot SEM (shaded)
%        legend_on - [true] / false
%
% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022 

if nargin < 6
    labels_on = true;
end
if nargin < 5 || isempty(plotShadedSEM)
    plotShadedSEM = false;
end
if nargin < 4 || isempty(stimValues)
    stimValues=xpr.stimValues;
end
if nargin < 3 || isempty(grp)
    grp=1;
end
if strcmp(xpr.sigName,'spks')
    sigMean = cellfun(@(x) squeeze(mean(x(cellNum,:,:),3)'),xpr.sorted_trials,'UniformOutput',false);
    y_label = 'Event density [a.u.]';
else
    sigMean = cellfun(@(x) squeeze(mean(x(cellNum,:,:),3)'),xpr.sorted_trials_dF_F0_bsl,'UniformOutput',false);
    y_label = '\DeltaF/F';
end
sigMean = [sigMean{:,grp}];
p = plot(xpr.t,sigMean);

if plotShadedSEM
    %Ntrials = size(sig.trials,3);
    % = cellfun(@(x) size(x,3),sig.sorted_trials_dF_F,'UniformOutput',false);

    %sigSEM  = squeeze(std(sig.trials_dF_F(roiNum,:,:),0,3)./sqrt(Ntrials));
    sigSEM = cellfun(@(x) squeeze(std(x(cellNum,:,:),0,3)'./sqrt(size(x,3))),xpr.sorted_trials_dF_F0_bsl,'UniformOutput',false);
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
if labels_on
    %xline([0 sig.stim_dur],':',{'stim ON', 'stim OFF'});;
    xline(0,':','stim ON');
    xline(xpr.stim_dur,':','stim OFF');
    xlabel('time [s]')
    ylabel(y_label)
    legend(num2str(stimValues(:)),'Location','northwest');
    title(['CELL#: ' num2str(cellNum) ', ROI#: ' num2str(xpr.cellIDs(cellNum))]);
else
    xline(0,':')
    xline(xpr.stim_dur,':')
end
return