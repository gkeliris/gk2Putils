% gks_pipeline

%% Extract stimulus information
% go to folder with h5 file
h5 = gk_readH5('OR_M19_0001.h5');
stim.Times = gk_getStimTimes(h5);
stim.Times = gk_getTimeStamps2P(stim.Times);
stim.Times = gk_getStimFrameTimes(stim.Times);

% load the stimulus types and random sequence from the matlab files
load('D:\2 visual stimulus files\orientation.mat')
stim.IDs=[Stims];
stim.Values=StimTyps;

% save this for easy access later
save('stim','stim');


%% Load Signal (from suite2P) and stimulus information to split to trials 

%load stimulus info (if not loaded from above)
load('stim.mat');

%load('suite2p/combined/Fall.mat','spks');
load('suite2p/combined/Fall.mat','F');
% Use the function gk_getSigTrials to collect signal trials
sig = gk_getSigTrials(F,stim,2,3);

% identify tuned neurons
for neuron=1:size(sig.trials,1)
    pON(neuron)=anova1(squeeze(sig.trials_ONresp(neuron,:,:)),[],"off");
    pOFF(neuron)=anova1(squeeze(sig.trials_OFFresp(neuron,:,:)),[],"off");
end

p_thr = 0.0001;
isOnTuned=pON<p_thr;
onTunedIDs = find(isOnTuned);
isOffTuned=~isOnTuned & pOFF<p_thr;
offTunedIDs= find(isOffTuned);

[~, si]= sort(pON(onTunedIDs));
% plot some neurons to see
for neuron=[onTunedIDs(si)]
    subplot(1,2,1);
    gk_plot_trials(sig, neuron, stim.Values, true)
    subplot(1,2,2);
    gk_plot_tuning(sig, neuron, stim.Values, 'orientation [deg]')
    pause(0.25);
    input('press enter to continue\n')
    clf
end

