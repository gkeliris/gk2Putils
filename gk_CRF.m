function CRF = gk_CRF(ds,sigName,t_before,t_after,pthr)
% USAGE: CRF = gk_CRF(ds,sigName,t_before,t_after,pthr)
%
% Author: Georgios A. Keliris
ds = gk_selectDS(ds);
xpr = gk_getTunedROIs(ds,sigName,t_before,t_after,pthr);
ROIs=[xpr.onTunedIDs_allGrp(xpr.sortedOnTunedIDs_allGrp)]';
CRF = gk_get_CRFs(xpr, ROIs);