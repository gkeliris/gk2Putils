function sig = gk_getSigTrials(sigMat, stim, t_before_sec, t_after_sec)


t_before_frames = round(t_before_sec*stim.Times.frame_fs);
t_after_frames = round(t_after_sec*stim.Times.frame_fs);
t_dur=stim.Times.median_frame_duration;

trial_dur=t_before_frames + t_dur + t_after_frames;

ind_from = stim.Times.frame_onsets-t_before_frames;
ind_to = stim.Times.frame_onsets + t_dur + t_after_frames -1;

for typ = 1:numel(stim.Values)
    sig(typ).ind=find(stim.IDs==typ);
    fromTo = [];
    for tr=1:numel(sig(typ).ind)
        fromTo = [fromTo ...
         ind_from(sig(typ).ind(tr)):ind_to(sig(typ).ind(tr))];
    end
    temp = sigMat(:,fromTo);
    sig(typ).trials = reshape(temp,[size(temp,1), trial_dur, numel(sig(typ).ind)]);
end

