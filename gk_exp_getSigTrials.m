function xpr = gk_exp_getSigTrials(coh,wk,ms,ex,sigName,t_before_sec, t_after_sec)


load('D:\all_exp_description.mat');

if isfile(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'stim.mat'))
    load(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'stim.mat'));
else
    fprintf('%s, %s, %s, %s: stim.mat is not yet created\n',coh,wk,ms,ex)
    return
end

if ~isfield(stim,'IDs')
    fprintf('%s, %s, %s, %s: addStimulus info missing\n',coh,wk,ms,ex)
    return
end

sig = readNPY(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'suite2p/combined/',[sigName,'.npy']));
if strcmp(stim.expType,'contrast')
    if strcmp(ms,'M19') && strcmp(wk,'w11')
        nAngles=3;
    else
        nAngles=4;
    end
elseif strcmp(stim.expType,'SF') || strcmp(stim.expType,'TF')
    nAngles=4;
else
    nAngles=1;
end
xpr = gk_getSigTrialsAngles(sig,stim,t_before_sec, t_after_sec, nAngles);
xpr.cohort=coh;
xpr.timepoint=wk;
xpr.mouse=ms;
xpr.sigName=sigName;



