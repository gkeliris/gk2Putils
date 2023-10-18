function sig = gk_getSigAllTrials(sigMat, stim, t_before_sec, t_after_sec)
% USAGE: sig = gk_getSigAllTrials(sigMat, stim, t_before_sec, t_after_sec)
%
% Author: Georgios A. Keliris

sig.expType=stim.expType;

z=1; %for multiplane ROIs that could have different timing, we use the 1st

% Calculate the number of frames before, during, and after stimulus onset
t_before_frames = round(t_before_sec*stim.Times.frame_fs(z));
t_after_frames = ceil(t_after_sec*stim.Times.frame_fs(z));
t_dur=stim.Times.median_frame_duration(z);
% Calculate the total trial duration
trial_dur=t_before_frames + t_dur + t_after_frames;

sig.stimValues=stim.Values;
sig.t=[-t_before_frames:(t_dur + t_after_frames -1)]./stim.Times.frame_fs(z);
sig.stim_dur=median(stim.Times.offsets-stim.Times.onsets);
sig.stimIDs=stim.IDs;
if isfield(stim,'Angles')
    sig.stimAngles=stim.Angles;
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
sig.trials= reshape(temp,[size(temp,1), trial_dur, numel(i_from)]);
sig.trials_dF_F = (sig.trials ./ repmat(mean(sig.trials(:,t_before_frames-3:t_before_frames+1,:),2),[1,trial_dur,1])) - 1 ;
sig.trials_ONresp = squeeze(mean(sig.trials_dF_F(:,t_before_frames+3:t_before_frames+t_dur,:),2));
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



