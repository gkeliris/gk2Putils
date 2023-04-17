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
xpr = gk_getSigTrials(sig,stim,t_before_sec, t_after_sec);
xpr.cohort=coh;
xpr.timepoint=wk;
xpr.mouse=ms;
xpr.sigName=sigName;



