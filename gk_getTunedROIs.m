function xpr = gk_getTunedROIs(ds,sigName,before,after,p_thr,xpr_recalc,plane)
% USAGE: xpr = gk_getTunedROIs(ds,sigName,before[s],after[s],p_thr,[force_save],[plane])
%
% Uses anova1 on the responses and if significant based on p_thr assigns
% the ROI as tuned
%
% INPUT:
%   ds :        the output of gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   before:     seconds before stim onset
%   after:      seconds after stim offset
%   pthr:       p-value to select ROIs as tuned
%   [plane]:    'combined' or 'plane0','plane1',... or 0,1,...
%
% Author: Georgios A. Keliris
%
% See also gk_exp_getSigTrials, gk_getCellTrials
ds = gk_selectDS(ds);
if nargin < 6
    xpr_recalc=false;
end
if nargin < 7
    plane = 'combined';
end
saveFilename=['xpr_', sigName, '_bef:',num2str(before), '_aft:', num2str(after),...
    '_pthr:', sprintf('%.1e',p_thr), '_', plane, '.mat'];

if isfile(fullfile(setSesPath(ds), 'matlabana',saveFilename)) && ~xpr_recalc
    load(fullfile(setSesPath(ds), 'matlabana',saveFilename));
    xpr.saveFilename=saveFilename;
else
    
    xpr = gk_exp_getSigTrials(ds,sigName,before,after,plane);
    
    if isfield(xpr,'stimAngles')
        nGrps=numel(unique(xpr.stimAngles));
    else
        nGrps=1;
    end
    
    for g=1:nGrps
        
        for r=1:size(xpr.trials,1)
            roi=gk_getCellTrials(xpr,r);
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
    xpr.saveFilename=saveFilename;
    save(fullfile(setSesPath(ds),'matlabana',xpr.saveFilename),'xpr')
end