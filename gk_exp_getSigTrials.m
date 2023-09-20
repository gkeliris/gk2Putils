function xpr = gk_exp_getSigTrials(coh,wk,ms,ex,sigName,t_before_sec, t_after_sec)


load('/mnt/Toshiba_16TB_1/all_exp_description.mat');

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
iscell = readNPY(fullfile(DES.(coh).(wk).(ms).(ex).procPath,'suite2p/combined/iscell.npy'));
sig = sig(find(iscell(:,1)),:);
% if strcmp(stim.expType,'contrast')
%     if strcmp(ms,'M19') && strcmp(wk,'w11')
%         nAngles=3;
%     else
%         nAngles=4;
%     end
% elseif strcmp(stim.expType,'SF') || strcmp(stim.expType,'TF')
%     nAngles=4;
% else
%     nAngles=1;
% end
if strcmp(stim.expType,'contrast')
    if strcmp(ms,'M19') && strcmp(wk,'w11')
        stim.Angles=[ones(length(stim.IDs)/3,1); 2*ones(length(stim.IDs)/3,1); 3*ones(length(stim.IDs)/3,1)];
    else
        stim.Angles=[ones(length(stim.IDs)/4,1); 2*ones(length(stim.IDs)/4,1); 3*ones(length(stim.IDs)/4,1); 4*ones(length(stim.IDs)/4,1)];
    end
elseif strcmp(stim.expType,'SF') || strcmp(stim.expType,'TF')
    stim.Angles=[ones(length(stim.IDs)/4,1); 2*ones(length(stim.IDs)/4,1); 3*ones(length(stim.IDs)/4,1); 4*ones(length(stim.IDs)/4,1)];
end
%xpr = gk_getSigTrialsAngles(sig,stim,t_before_sec, t_after_sec, nAngles);
xpr = gk_getSigAllTrials(sig,stim,t_before_sec, t_after_sec);
xpr.cellIDs=find(iscell(:,1));
xpr.cohort=coh;
xpr.timepoint=wk;
xpr.mouse=ms;
xpr.sigName=sigName;




