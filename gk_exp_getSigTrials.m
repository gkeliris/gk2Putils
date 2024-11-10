function xpr = gk_exp_getSigTrials(ds,sigName,t_before_sec, t_after_sec,plane,Fneu_factor)
% USAGE: xpr = gk_exp_getSigTrials(ds,sigName,t_before_sec, t_after_sec,[plane],[Fneu_factor])
%
% INPUT:
%   ds :    the output of gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   t_before_sec: seconds before stim onset
%   t_after_sec:  seconds after stim offset
%   plane:        'combined' or 'plane0','plane1',... or 0,1,...
%   Fneu_factor:  p-value to select ROIs as tuned
%
% Author: Georgios A. Keliris
%
% See also gk_getSigAllTrials, readNPY

if nargin < 6
    Fneu_factor = false;
end
if nargin < 5
    plane = 'combined';
end

ds = gk_selectDS(ds);
stim = loadStim(ds);
sig = loadSig(ds,sigName,plane);
if Fneu_factor
    Fneu=loadSig(ds,'Fneu',plane);
    %sig=sig-0.3*repmat(stimA.v',size(sig,1),1);
    sig=sig-Fneu_factor*Fneu;
end
iscell = loadSig(ds,'iscell',plane);
sig = sig(logical(iscell(:,1)),:);

if (strcmp(ds.cohort,'coh1') || strcmp(ds.cohort,'coh2') ) && ...
        (strcmp(ds.expID,'contrast') || strcmp(ds.expID,'SF') || strcmp(ds.expID,'TF'))
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

xpr = gk_getSigAllTrials(sig,stim,t_before_sec, t_after_sec);

xpr.cellIDs=find(iscell(:,1));
xpr.cohort=ds.cohort;
xpr.timepoint=ds.week;
xpr.mouse=ds.mouseID;
xpr.sigName=sigName;
xpr.plane=plane;




