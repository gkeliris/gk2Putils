function [sigMeanON, sigSemON] = gk_get_tuning(sig, roiNum)
% USAGE: gk_get_tuning(sig, roiNum, stimValues)
%
% Function that gets the tuning function of roi/neuron
%
% Input: sig - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in sig
%
% Author: Georgios A. Keliris
% v1.0 - 27 Dec 2022 

Ntrials = size(sig.trials_ONresp,2); 
sigMeanON = squeeze(mean(sig.trials_ONresp(roiNum,:,:),2));
sigSemON = squeeze(std(sig.trials_ONresp(roiNum,:,:),0,2)./sqrt(Ntrials));

%sigMeanOFF= squeeze(mean(sig.trials_OFFresp(roiNum,:,:),2));
%sigSemOFF = squeeze(std(sig.trials_OFFresp(roiNum,:,:),0,2)./sqrt(Ntrials));

return