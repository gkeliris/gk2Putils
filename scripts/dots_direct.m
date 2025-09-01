%% DOTS direct analysis

ds=gk_directLoadTiffs;
ds.expID='5dots';
stim=gk_getRetinotopyStim([],[1000 3500 6000 Inf]);

%% First way to analyze (use Fourier like for the bar Retinotopy)
FTS_dots = gk_direct_retPhaseAmp(ds, false, true, stim, 0, false);
% Note: The FTS_dots.amp should have the pixels that are modulated by the
% dots and the FTS_dots.phs should have different phases for those pixels
% depending on which dot they are driven by


%% Second way to analyze (average the images for each dot)
% Note: for this we first need to convert the continuous time series to
% trials and then average certain frames that can be assigned to each dot

% In order to average the stitched images we first need to stitch
ds = gk_stitch(ds);

% To cut out trials first define the time before and after to extract
t_pre_sec=1; 
t_post_sec=1;
% convert this time to frames using the sampling rate
t_pre_frames=ceil(t_pre_sec*stim.Times.frame_fs);
t_post_frames=ceil(t_post_sec*stim.Times.frame_fs);
% also use the duration of the presentation in frames
t_stimdur_frames=stim.Times.median_frame_duration;
% and calculate the total trial duration as a sum of all three durations
trial_dur_frames=t_pre_frames+t_stimdur_frames+t_post_frames;

% Now iterate and convert to trials
for v=1:numel(stim.Values)
    trialIndices=find(stim.IDs==v);
    ds.trials{v}=zeros([size(ds.stitched,[1,2]) trial_dur_frames numel(trialIndices)]);
    for i=1:numel(trialIndices)
        idx=trialIndices(i);
        ds.trials{v}(:,:,1:trial_dur_frames,i)=ds.stitched(:,:,...
            stim.Times.frame_onsets(idx)-t_pre_frames:...
            stim.Times.frame_onsets(idx)+t_stimdur_frames+t_post_frames-1);
    end
end

% Now we can average the frames for each dot as follows (example for dot1)

% the pre time is 5 frames the stimulus is 5 frames and the post is 5
% frames, since the stimulus needs some time to go up and down we can take
% frames 8-13 as a first approximation of the peak activity.
dot1=mean(ds.trials{1}(:,:,8:27,:),[3,4]);

% However this is the raw signal, probably is best to convert to DeltaF/F
% One way to do this is to use the pre time of each dot as baseline
bsl1=mean(ds.trials{1}(:,:,3:5,:),[3,4]);

% and convert to deltaF/F
dot1_dF = (dot1-bsl1)./bsl1;


