function sig = gk_getSigAllTrials(sigMat, stim, t_before_sec, t_after_sec)
% USAGE: sig = gk_getSigAllTrials(sigMat, stim, t_before_sec, t_after_sec)
%
% Author: Georgios A. Keliris

sig.expType=stim.expType;

z=1; %for multiplane ROIs that could have different timing, we use the 1st

% Calculate F0
baseline_dur=20; % seconds
baseline_frames=round(baseline_dur*stim.Times.frame_fs(z));
F0_index=stim.Times.frame_onsets(z,1)-baseline_frames:stim.Times.frame_onsets(z,1)-1;
if F0_index(1)<0
    F0_index=F0_index(F0_index>0);
    fprintf('Warning: not enough baseline but taking the median from %f sec\n',...
        numel(F0_index)/stim.Times.frame_fs(z));
end
F0_bsl=median(sigMat(:,F0_index),2);

% Calculate the number of frames before, during, and after stimulus onset
t_before_frames = round(t_before_sec*stim.Times.frame_fs(z));
t_after_frames = ceil(t_after_sec*stim.Times.frame_fs(z));
t_dur=stim.Times.median_frame_duration(z);
if t_dur/stim.Times.frame_fs < 2
    t_ext_sec = 1; % extend the duration for 1 sec (for STIMON period)
    t_ext = ceil(t_ext_sec*stim.Times.frame_fs);
else
    t_ext = 0;
end
% Calculate the total trial duration
trial_dur=t_before_frames + t_dur + t_after_frames;

sig.stimValues=stim.Values;
sig.t=[-t_before_frames:(t_dur + t_after_frames -1)]./stim.Times.frame_fs(z);
sig.stim_dur=median(stim.Times.offsets-stim.Times.onsets);
sig.stimIDs=stim.IDs;
if isfield(stim,'Angles')
    if ~isfield(stim,'AnglesValues')
        stim.AnglesValues=[0;90;120;210];
    end
    sig.stimAngles=stim.Angles;
    sig.stimAnglesValues=stim.AnglesValues;
    grps=unique(stim.Angles);
    nGrps=numel(grps);
else
    nGrps=1;
    grps=1;
end

Ntrials=numel(stim.IDs);
% Calculate indices to extract trials
i_from = stim.Times.frame_onsets(z,1:Ntrials)-t_before_frames;
i_to = stim.Times.frame_onsets(z,1:Ntrials) + t_dur + t_after_frames -1;

% Extract all trials
fromTo=[];
for tr=1:numel(i_from)
    fromTo = [fromTo i_from(tr):i_to(tr)];
end

temp=sigMat(:,fromTo);
sig.trials = reshape(temp,[size(temp,1), trial_dur, numel(i_from)]);
sig.trials_dF_F = (sig.trials ./ repmat(mean(sig.trials(:,t_before_frames-4:t_before_frames,:),2),[1,trial_dur,1])) - 1;
sig.trials_ONresp = squeeze(mean(sig.trials_dF_F(:,t_before_frames+3:t_before_frames+t_dur+t_ext,:),2));

sig.trials = (sig.trials ./ repmat(F0_bsl,1,size(sig.trials,2),size(sig.trials,3))) - 1;
sig.trials_ONresp_bsl = squeeze(mean(sig.trials(:,t_before_frames+3:t_before_frames+t_dur+t_ext,:),2));
%sig.trials_ONresp = squeeze(mean(sig.trials(:,t_before_frames+3:t_before_frames+t_dur+t_ext,:),2));
%sig.trials_OFFresp = squeeze(mean(sig.trials_dF_F(:,t_before_frames+t_dur+3:t_before_frames+t_dur+t_after_frames-3,:),2));

% sort trials to groups and stimuli (use cells to account for unequal
% number of trials)

for g=1:nGrps
    for s=1:numel(sig.stimValues)
        if nGrps>1
            ind = find(sig.stimIDs==s & sig.stimAngles==g);
        else
            ind = find(sig.stimIDs==s);
        end
        sig.sorted_trials{s,g} = sig.trials(:,:,ind);
        sig.sorted_trials_dF_F{s,g} = sig.trials_dF_F(:,:,ind);
        sig.sorted_trials_ONresp{s,g} = sig.trials_ONresp(:,ind);
    end
end



