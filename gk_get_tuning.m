function [sigMeanON, sigSemON] = gk_get_tuning(sig, roiNum, stimValues, xlabelStr)
% USAGE: gk_get_tuning(sig, roiNum, stimValues, [xlabelStr])
%
% Function that plots the tuning function of roi/neuron
%
% Input: sig - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in sig
%        stimValues - the type of stimuli stored in stim.Values
%        xlabelStr - a string to label the x axis (optional)
%
% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022 


if nargin == 3
    xlabelStr = 'stimulus parameter';
end

Ntrials = size(sig.trials_ONresp,2); 
sigMeanON = squeeze(mean(sig.trials_ONresp(roiNum,:,:),2));
sigSemON = squeeze(std(sig.trials_ONresp(roiNum,:,:),0,2)./sqrt(Ntrials));

sigMeanOFF= squeeze(mean(sig.trials_OFFresp(roiNum,:,:),2));
sigSemOFF = squeeze(std(sig.trials_OFFresp(roiNum,:,:),0,2)./sqrt(Ntrials));

errorbar(stimValues,sigMeanON,sigSemON,'ko-','MarkerFaceColor',[0 0 0]);
yline([0],'--');
xlabel(xlabelStr);
xlim padded
ylim padded
ylabel('\DeltaF/F');
title(['Num: ' num2str(roiNum)]);

% binangles=round(10000*(sigMeanON-min(sigMeanON))./sum(sigMeanON-min(sigMeanON)));
% samples=[];
% for s=1:numel(binangles)
%     samples=[samples; repmat(deg2rad(stimValues(s))-pi,binangles(s),1)];
% end
% nComponents = 2;
% fittedVmm = fitmvmdist(samples, nComponents, ...
%   'MaxIter', 250); % Set maximum number of EM iterations to 250
% 
% norm = sum(fittedVmm.pdf(unique(samples)));
% xangles = linspace(-pi, pi, 1000)';
% hold on;
% plot(rad2deg(xangles)+180,norm*fittedVmm.pdf(xangles)+min(sigMeanON),'r','LineWidth',1.5);

% [thetahat kappa] = circ_vmpar(deg2rad(stimValues)*2,sigMeanON-min(sigMeanON));
% [p alpha]=circ_vmpdf([],thetahat,kappa);
% hold on;
% plot(rad2deg(alpha)/2,p*sum(sigMeanON-min(sigMeanON))+min(sigMeanON),'r','LineWidth',1.5);

return