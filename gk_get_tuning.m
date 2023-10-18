function [sigMeanON, sigSemON] = gk_get_CRF(sig, roiNum, stimValues)
% USAGE: gk_get_CRF(sig, roiNum, stimValues)
%
% Function that gets the tuning function of roi/neuron
%
% Input: sig - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in sig
%
% Author: Georgios A. Keliris
% v1.0 - 27 Dec 2022


for grp=1:numel(xpr.grp)
    
    sigMeanON = cellfun(@(x) squeeze(mean(x(roiNum,:),2)),sig.sorted_trials_ONresp,'UniformOutput',false);
    sigMeanON = [sigMeanON{:,grp}];
    
    sigSemON = cellfun(@(x) squeeze(std(x(roiNum,:),0,2)./sqrt(size(x,2))),sig.sorted_trials_ONresp,'UniformOutput',false);
    sigSemON = [sigSemON{:,grp}];
end
return