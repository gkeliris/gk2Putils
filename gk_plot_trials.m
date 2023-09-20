function gk_plot_trials(sig, roiNum, grp, stimValues, plotShadedSEM)
% USAGE: gk_plot_trials(sig, roiNum, grp, stimValues, [plotShadedSEM=false])
%
% Function that plots the time courses for different stimulus types
%
% Input: sig - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in sig
%        stimValues - the type of stimuli stored in stim.Values
%        plotShadedSEM - if true will plot SEM (shaded)
%
% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022 


if nargin == 4
    plotShadedSEM = false;
end

%sigMean = squeeze(mean(sig.trials_dF_F(roiNum,:,:),3));
sigMean = cellfun(@(x) squeeze(mean(x(roiNum,:,:),3)'),sig.sorted_trials_dF_F,'UniformOutput',false);
sigMean = [sigMean{:,grp}];
p = plot(sig.t,sigMean);

if plotShadedSEM
    %Ntrials = size(sig.trials,3);
    % = cellfun(@(x) size(x,3),sig.sorted_trials_dF_F,'UniformOutput',false);

    %sigSEM  = squeeze(std(sig.trials_dF_F(roiNum,:,:),0,3)./sqrt(Ntrials));
    sigSEM = cellfun(@(x) squeeze(std(x(roiNum,:,:),0,3)'./sqrt(size(x,3))),sig.sorted_trials_dF_F,'UniformOutput',false);
    sigSEM = [sigSEM{:,grp}];
    if numel(stimValues)==1
        shadedErrorBar(sig.t,sigMean,sigSEM,...
            'lineprops',{'Color', p(1).Color}, 'transparent', 1);
    else
        for tr=1:numel(stimValues)
            shadedErrorBar(sig.t,sigMean(:,tr),sigSEM(:,tr),...
                'lineprops',{'Color', p(tr).Color}, 'transparent', 1);
        end
    end
    clear p
end

%xline([0 sig.stim_dur],':',{'stim ON', 'stim OFF'});
xline(0,':','stim ON');
xline(sig.stim_dur,':','stim OFF');
xlabel('time [s]')
ylabel('\DeltaF/F')
legend(num2str(stimValues),'Location','northeast');
title(['ROI#: ' num2str(roiNum)]);

return