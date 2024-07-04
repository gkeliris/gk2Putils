function [sigMean, sigSem] = gk_get_CRF(sig, roiNums, best)
% USAGE: crfs = gk_get_CRFs(sig, roiNums, best)
%
% Function that gets the tuning function of roi/neuron
%
% Input: sig - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in sig
%
% Author: Georgios A. Keliris
% v1.0 - 20 Sep 2023

if nargin < 3
    best=false;
end


for grp=1:numel(sig.grp)
    
    tmp = cellfun(@(x) squeeze(mean(x(roiNum,:),2)),sig.sorted_trials_ONresp,'UniformOutput',false);
    sigMean(grp,:) = [tmp{:,grp}];
    
    tmp = cellfun(@(x) squeeze(std(x(roiNum,:),0,2)./sqrt(size(x,2))),sig.sorted_trials_ONresp,'UniformOutput',false);
    sigSem(grp,:) = [tmp{:,grp}];
end
if best
    [~,maxInd]=max(sigMean,[],'all','linear');
    [row,col]=ind2sub(size(sigMean),maxInd);
    sigMean=sigMean(row,:);
    sigSem=sigSem(row,:);
end

return