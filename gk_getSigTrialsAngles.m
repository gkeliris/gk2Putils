function sig = gk_getSigTrialsAngles(sigMat, stim, t_before_sec, t_after_sec, nAngles)

sig.expType=stim.expType;
z=1; %for multiplane ROIs that could have different timing, we use the 1st

% Calculate the number of frames before, during, and after stimulus onset
t_before_frames = round(t_before_sec*stim.Times.frame_fs(z));
t_after_frames = ceil(t_after_sec*stim.Times.frame_fs(z));
t_dur=stim.Times.median_frame_duration(z);
% Calculate the total trial duration
trial_dur=t_before_frames + t_dur + t_after_frames;

Ntrials=numel(stim.IDs);
% Calculate indices to extract trials
ind_from = stim.Times.frame_onsets(z,1:Ntrials)-t_before_frames;
ind_to = stim.Times.frame_onsets(z,1:Ntrials) + t_dur + t_after_frames -1;

% Ntrials/4 trials per angle
ind_from = reshape(ind_from, Ntrials/nAngles, nAngles);
ind_to = reshape(ind_to, Ntrials/nAngles, nAngles);

nNeurons = size(sigMat,1);
% iterate for each stimulus type and collect trials
% this also calculates dF/F and responses during ON and OFF periods
for angle=1:nAngles
    % Calculate trial t (stim onset = 0)
    sig.grp(angle).stimValues=stim.Values;
    sig.grp(angle).t=[-t_before_frames:(t_dur + t_after_frames -1)]./stim.Times.frame_fs(z);
    sig.grp(angle).stim_dur = median(stim.Times.offsets-stim.Times.onsets);
    for typ = 1:numel(stim.Values)
        % get the trials with same stimulus type
        ind=find(stim.IDs(Ntrials/nAngles*(angle-1)+1:Ntrials/nAngles*angle)==typ);
        fromTo = [];
        for tr=1:numel(ind)
            fromTo = [fromTo ...
                ind_from(ind(tr),angle):ind_to(ind(tr),angle)];
        end
        temp = sigMat(:,fromTo);
        % get trials, calculate dF/F and responses
        trials = reshape(temp,[size(temp,1), trial_dur, numel(ind)]);
        trials_dF_F = (trials ./ repmat(mean(trials(:,1:t_before_frames,:),2),[1,trial_dur,1])) - 1 ;
        trials_ONresp = mean(trials_dF_F(:,t_before_frames+3:t_before_frames+t_dur,:),2);
        trials_OFFresp = mean(trials_dF_F(:,t_before_frames+t_dur+3:t_before_frames+t_dur+t_after_frames-3,:),2);
        % save to sig structure that is returned by the function
        sig.grp(angle).trials(:,:,:,typ) = trials;
        sig.grp(angle).trials_dF_F(:,:,:,typ) = trials_dF_F;
        sig.grp(angle).trials_ONresp(:,:,typ) = squeeze(trials_ONresp);
        sig.grp(angle).trials_OFFresp(:,:,typ) = squeeze(trials_OFFresp);

    end
end

