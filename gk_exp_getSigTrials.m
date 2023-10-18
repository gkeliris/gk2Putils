function xpr = gk_exp_getSigTrials(coh,wk,ms,ex,sigName,t_before_sec, t_after_sec,Fneu_factor)
% USAGE: xpr = gk_exp_getSigTrials(coh,wk,ms,ex,sigName,t_before_sec, t_after_sec,[Fneu_factor])
%
% Author: Georgios A. Keliris

if nargin < 8
    Fneu_factor = false;
end

load('/mnt/Toshiba_16TB_1/all_exp_description.mat');

if isfile(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'stim.mat'))
    load(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'stim.mat'));
    if Fneu_factor
%         load(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'stimA.mat'));
        Fneu=readNPY(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'suite2p/combined/',['Fneu','.npy']));
    end
else
    fprintf('%s, %s, %s, %s: stim.mat is not yet created\n',coh,wk,ms,ex)
    return
end

if ~isfield(stim,'IDs')
    fprintf('%s, %s, %s, %s: addStimulus info missing\n',coh,wk,ms,ex)
    return
end

sig = readNPY(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'suite2p/combined/',[sigName,'.npy']));
if Fneu_factor
    %sig=sig-0.3*repmat(stimA.v',size(sig,1),1);
    sig=sig-Fneu_factor*Fneu;
end
iscell = readNPY(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'suite2p/combined/iscell.npy'));
sig = sig(find(iscell(:,1)),:);

if (strcmp(coh,'coh1') || strcmp(coh,'coh2') ) && ...
        (strcmp(ex,'contrast') || strcmp(ex,'SF') || strcmp(ex,'TF'))
    stim.Angles=[ones(length(stim.IDs)/4,1); 2*ones(length(stim.IDs)/4,1);...
        3*ones(length(stim.IDs)/4,1); 4*ones(length(stim.IDs)/4,1)];
end
%xpr = gk_getSigTrialsAngles(sig,stim,t_before_sec, t_after_sec, nAngles);
xpr = gk_getSigAllTrials(sig,stim,t_before_sec, t_after_sec);
xpr.cellIDs=find(iscell(:,1));
xpr.cohort=coh;
xpr.timepoint=wk;
xpr.mouse=ms;
xpr.sigName=sigName;




