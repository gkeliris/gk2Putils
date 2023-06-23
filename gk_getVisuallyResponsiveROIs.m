function xpr = gk_getVisuallyResponsiveROIs(xpr,p_thr)

for g=1:numel(xpr.grp)
    for roi=1:size(xpr.grp(g).trials,1)
        [pON(roi,g),tbl{roi,g},stats{roi,g}]=anova1(squeeze(xpr.grp(g).trials_ONresp(roi,:,:)),[],"off");
        pOFF(roi,g)=anova1(squeeze(xpr.grp(g).trials_OFFresp(roi,:,:)),[],"off");
        xpr.grp(g).pON=pON(roi,g);
        xpr.grp(g).tbl{roi}=tbl{roi,g};
        xpr.grp(g).stats{roi}=stats{roi,g};
        xpr.grp(g).pOFF=pOFF(roi,g);
    end

    xpr.grp(g).isOnTuned=xpr.grp(g).pON<p_thr;
    xpr.grp(g).onTunedIDs = find(xpr.grp(g).isOnTuned);
    xpr.grp(g).pThr=p_thr;
    [~, xpr.grp(g).sortedOnTunedIDs]= sort(xpr.grp(g).pON(xpr.grp(g).onTunedIDs));
end
xpr.pON=pON;
xpr.pONmin=min(pON,[],2);
xpr.pOFF=pOFF;
xpr.pOFFmin=min(pOFF,[],2);
xpr.pThr=p_thr;
xpr.isOnTuned_allGrp=xpr.pONmin<p_thr;
xpr.onTunedIDs_allGrp = find(xpr.isOnTuned_allGrp);
[~, xpr.sortedOnTunedIDs_allGrp]= sort(xpr.pONmin(xpr.onTunedIDs_allGrp));