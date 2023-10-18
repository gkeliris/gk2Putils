function xpr = gk_getTunedROIs(coh,wk,ms,ex,sig,before,after,p_thr)
% USAGE: xpr = gk_getTunedROIs(coh,wk,ms,ex,sig,before,after,p_thr)
%
% INPUT:
%
% Author: Georgios A. Keliris
Fneu_factor=0;

xpr = gk_exp_getSigTrials(coh,wk,ms,ex,sig,before,after,Fneu_factor);
if isfield(xpr,'stimAngles')
    nGrps=numel(unique(xpr.stimAngles));
else
    nGrps=1;
end

for g=1:nGrps
    
    for r=1:size(xpr.trials,1)  
        roi=gk_getRoiTrials(xpr,r);
        grp=roi.responses(roi.responses.grpID==g,1:2);
        pON(r,g)=anova1(grp.ONresp, grp.stimID,"off");
        
    end
    xpr.grp(g).pON=pON(:,g);
    xpr.grp(g).isOnTuned=xpr.grp(g).pON<p_thr;
    xpr.grp(g).onTunedIDs = find(xpr.grp(g).isOnTuned);
    xpr.grp(g).pThr=p_thr;
    [~, xpr.grp(g).sortedOnTunedIDs]= sort(xpr.grp(g).pON(xpr.grp(g).onTunedIDs));
end
xpr.pON=pON;
xpr.pONmin=min(pON,[],2);

xpr.pThr=p_thr;
xpr.isOnTuned_allGrp=xpr.pONmin<p_thr;
xpr.onTunedIDs_allGrp = find(xpr.isOnTuned_allGrp);
[~, xpr.sortedOnTunedIDs_allGrp]= sort(xpr.pONmin(xpr.onTunedIDs_allGrp));
xpr.tunedGlobalIDs=xpr.cellIDs(xpr.onTunedIDs_allGrp(xpr.sortedOnTunedIDs_allGrp));