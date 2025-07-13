function xpr = gk_exp_getSigTrialsFissa(ds,sigName,t_before_sec, t_after_sec,plane)
% USAGE: xpr = gk_exp_getSigTrialsFissa(ds,sigName,t_before_sec, t_after_sec,plane)
%
% INPUT:
%   ds :    the output of gk_datasetQuery
%   sigName:    'result','raw', 'deltaf_result', 'deltaf_raw',...
%   t_before_sec: seconds before stim onset
%   t_after_sec:  seconds after stim offset
%   plane:        'plane0','plane1',... or 0,1,...
%
%
% Author: Georgios A. Keliris
%
% See also gk_getSigAllTrials, readNPY


ds = gk_selectDS(ds);
stim = loadStim(ds);
sig = loadFissa(ds,sigName,plane);
iscell = loadSig(ds,'iscell',plane);
if (strcmp(ds.cohort,'coh1') || strcmp(ds.cohort,'coh2') ) && ...
        (strfind(ds.expID,'contrast') || strfind(ds.expID,'SF') || strfind(ds.expID,'TF'))
    if length(stim.IDs)>560
        stim.IDs=stim.IDs(1:560);
    end
    try
        stim.Angles=[ones(length(stim.IDs)/4,1); 2*ones(length(stim.IDs)/4,1);...
            3*ones(length(stim.IDs)/4,1); 4*ones(length(stim.IDs)/4,1)];
    catch
        stim.Angles=[ones(560/4,1); 2*ones(560/4,1);...
            3*ones(560/4,1); 4*ones(560/4,1)];
        stim.Angles=stim.Angles(1:length(stim.IDs));
    end
    if ~isfield(stim,'AnglesValues')
        stim.AnglesValues=[0 90 120 210]';
    else
        stim.AnglesValues=stim.AnglesValues(:);
    end
        
end
if contains(sigName,'deltaf')
    calcDF=false;
else
    calcDF=true;
end
xpr = gk_getSigAllTrials(sig,stim,t_before_sec, t_after_sec, calcDF);
xpr.ds=ds;
xpr.cellIDs=find(iscell(:,1));
xpr.cohort=ds.cohort;
xpr.timepoint=ds.day;
xpr.mouse=ds.mouseID;
xpr.sigName=sigName;
xpr.plane=plane;




