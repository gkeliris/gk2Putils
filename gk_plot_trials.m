function gk_plot_trials(sig, roiNum, stimValues, plotShadedSEM)
% USAGE: gk_plot_trials(sig, roiNum, stimValues, [plotShadedSEM=false])
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


if nargin == 3
    plotShadedSEM = false;
end

sigMean = squeeze(nanmean(sig.trials_dF_F(roiNum,:,:,:),3));
p = plot(sig.t,sigMean);

if plotShadedSEM
    Ntrials = size(sig.trials,3);    
    sigSEM  = squeeze(nanstd(sig.trials_dF_F(roiNum,:,:,:),0,3)./sqrt(Ntrials));
    for tr=1:numel(stimValues)
        shadedErrorBar(sig.t,sigMean(:,tr),sigSEM(:,tr),...
            'lineprops',{'Color', p(tr).Color}, 'transparent', 1);
    end
    clear p
end

xline([0 sig.stim_dur],':',{'stim ON', 'stim OFF'});
xlabel('time [s]')
ylabel('\DeltaF/F')
legend(num2str(stimValues));
title(['Num: ' num2str(roiNum)]);

return