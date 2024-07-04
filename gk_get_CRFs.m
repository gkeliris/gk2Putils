function crfs = gk_get_CRFs(xpr, roiNums)
% USAGE: crfs = gk_get_CRFs(xpr, roiNums)
%
% Function that gets the tuning function of roi/neuron
%
% Input: xpr - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in xpr
%
% Author: Georgios A. Keliris
% v1.0 - 20 Sep 2023

for r=1:numel(roiNums)
    roiNum=roiNums(r);
    
    for grp=1:numel(xpr.grp)
        
        
        tmp = cellfun(@(x) squeeze(mean(x(roiNum,:),2)),xpr.sorted_trials_ONresp,'UniformOutput',false);
        sigMean(grp,:) = [tmp{:,grp}];
        
        tmp = cellfun(@(x) squeeze(std(x(roiNum,:),0,2)./sqrt(size(x,2))),xpr.sorted_trials_ONresp,'UniformOutput',false);
        sigSem(grp,:) = [tmp{:,grp}];
    end
    [~,maxInd]=max(sigMean,[],'all','linear');
    [row,col]=ind2sub(size(sigMean),maxInd);
    crfs.sigMean(r,:)=sigMean(row,:);
    crfs.sigSem(r,:)=sigSem(row,:);
    if col<=7
        crfs.lowCon(r,1)=1;
    else
        crfs.lowCon(r,1)=0;
    end
    crfs.allTrials{r} = cellfun(@(x) x(roiNum,row),xpr.sorted_trials_ONresp,'UniformOutput',false);
end
crfs.lowSum=sum(crfs.lowCon);
crfs.lowPerc=crfs.lowSum/numel(crfs.lowCon)*100;
crfs.roiNums=roiNums';
crfs.stimValues=xpr.stimValues;
crfs.allTrials=xpr.sorted_trials_ONresp;
return