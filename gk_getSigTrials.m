function sig = gk_getSigTrials(sigMat, stim, t_before_sec, t_after_sec)
% USAGE: sig = gk_getSigTrials(sigMat, stim, t_before_sec, t_after_sec)
%
% Function that extracts the trials from the suite2P matrix e.g. F, spks
%
% Input: sigMat - the matrix loaded from suite2P
%        stim - the stimulus information (saved in stim.mat)
%        t_before_sec - time before stimulus onset in seconds
%        t_after_sec - time after stimulus offset in seconds
%
% Output: sig - a structure containing fields 
%            .trials - the requested trials
%            .trials_dF_F - trials converted using the t_before_sec
%            .ONresp - the average responses after stim onset
%            .OFFresp - the average responses after stim offset
%            .t - the time in seconds (to use for ploting)
%
% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022 


z=1; %for multiplane ROIs that could have different timing, we use the 1st

% Calculate the number of frames before, during, and after stimulus onset
t_before_frames = round(t_before_sec*stim.Times.frame_fs(z));
t_after_frames = ceil(t_after_sec*stim.Times.frame_fs(z));
t_dur=stim.Times.median_frame_duration(z);
% Calculate the total trial duration
trial_dur=t_before_frames + t_dur + t_after_frames;

% Calculate trial t (stim onset = 0)
sig.t=[-t_before_frames:(t_dur + t_after_frames -1)]./stim.Times.frame_fs(z);
sig.stim_dur = median(stim.Times.offsets-stim.Times.onsets);

% Calculate indices to extract trials
ind_from = stim.Times.frame_onsets(z,:)-t_before_frames;
ind_to = stim.Times.frame_onsets(z,:) + t_dur + t_after_frames -1;

% iterate for each stimulus type and collect trials
% this also calculates dF/F and responses during ON and OFF periods
for typ = 1:numel(stim.Values)
    
    ind=find(stim.IDs==typ); % trials with same stimulus type

    fromTo = [];
    for tr=1:numel(ind)
        fromTo = [fromTo ...
            ind_from(ind(tr)):ind_to(ind(tr))];
    end
    temp = sigMat(:,fromTo);
    % get trials, calculate dF/F and responses
    trials = reshape(temp,[size(temp,1), trial_dur, numel(ind)]);
    trials_dF_F = (trials ./ repmat(mean(trials(:,1:t_before_frames,:),2),[1,trial_dur,1])) - 1 ;
    trials_ONresp = mean(trials_dF_F(:,t_before_frames+3:t_before_frames+t_dur,:),2);
    trials_OFFresp = mean(trials_dF_F(:,t_before_frames+t_dur+3:t_before_frames+t_dur+t_after_frames-3,:),2);
    
    % save to sig structure that is returned by the function
    sig.trials(:,:,:,typ) = trials;
    sig.trials_dF_F(:,:,:,typ) = trials_dF_F;
    sig.trials_ONresp(:,:,typ) = squeeze(trials_ONresp);
    sig.trials_OFFresp(:,:,typ) = squeeze(trials_OFFresp);

end


