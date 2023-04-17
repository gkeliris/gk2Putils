function xpr = gk_getTunedROIs(xpr,p_thr)

for roi=1:size(xpr.trials,1)
    xpr.pON(roi)=anova1(squeeze(xpr.trials_ONresp(roi,:,:)),[],"off");
    xpr.pOFF(roi)=anova1(squeeze(xpr.trials_OFFresp(roi,:,:)),[],"off");
end

xpr.isOnTuned=xpr.pON<p_thr;
xpr.onTunedIDs = find(xpr.isOnTuned);
xpr.isOffTuned=~xpr.isOnTuned & xpr.pOFF<p_thr;
xpr.offTunedIDs= find(xpr.isOffTuned);
xpr.pThr=p_thr;
[~, xpr.sortedOnTunedIDs]= sort(xpr.pON(xpr.onTunedIDs));