function xpr = gk_sortFit(xpr, weight1, weigth2)
% USAGE: xpr = gk_sortFit(xpr,[weight1],[weight2])
%
%  INPUT:
%       xpr (output of gk_calc_tuning)
%       weight1, def:0.5 [0,1] 0: RespMedian 100%, 1: RespMax 100% -> score
%       weight2, def:0.5 [0,1] 0: Rsquare: 100%, 1: score 100% -> mixScore
%
% OUTPUT:
%       adding fields sorting neurons in xpr

% Author: Georgios A. Keliris
%   14 Nov 2025

if nargin < 3; weight2 = 0.5; end
if nargin < 2; weight1 = 0.5; end    

%% SORT Neurons based on fit quality / amplitude of responses

maxResp = cellfun(@(x) x.maxResp, xpr.tuning_params);
medianResp = cellfun(@(x) x.medianResp, xpr.tuning_params);
adjR2 = cellfun(@(x) x.gof.adjrsquare, xpr.tuning_params);
scores = (1-weight1).*medianResp + weight1.*maxResp;
mixScores = (1-weight2).*adjR2 +weight2.*scores;
if numel(xpr.grp)>1
    [~, xpr.grpOrder]=sort(scores,2,"descend");
    for cellNum = 1:numel(xpr.tunedGlobalIDs)
        adjR2(cellNum,:) = adjR2(cellNum,xpr.grpOrder(cellNum,:));
        [adjR2(cellNum,:),k] = sort(adjR2(cellNum,:),"descend");
        xpr.grpOrder(cellNum,:)=xpr.grpOrder(cellNum,k);
    end
[xpr.adjR2_sorted,xpr.adjR2_cellSort]=sortrows(adjR2,"descend");
xpr.adjR2_grpPref=xpr.grpOrder(xpr.adjR2_cellSort,1);   
else
    [xpr.adjR2_sorted,xpr.adjR2_cellSort]=sort(adjR2,"descend");
    [xpr.score_sorted,xpr.score_cellSort]=sort(scores,"descend");
    [xpr.mixScore_sorted,xpr.mixScore_cellSort]=sort(mixScores,"descend");
end
return
       