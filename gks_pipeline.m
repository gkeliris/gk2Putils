% gks_pipeline

% go to folder with h5 file
h5 = gk_readH5('SF_M19_0001.h5');
stim.Times = gk_getStimTimes(h5);
stim.Times = gk_getTimeStamps2P(stim.Times);
stim.Times = gk_getStimFrameTimes(stim.Times);


% load the stimulus types and random sequence from the matlab files
load('D:\2 visual stimulus files\SF.mat')
% for spatial Frequency we have 400 trials, 100 x 4 angles (0, 90, 120,
% 210)
stim.IDs=[Stims(1:100); Stims(1:100); Stims(1:100); Stims(1:100)];
stim.Values=StimTyps;
% save this for easy access later
save('stim','stim');

% load a signal and split it to trials

%load('suite2p/combined/Fall.mat','spks');
load('stim.mat');
load('suite2p/combined/Fall.mat','iscell');
load('suite2p/combined/Fall.mat','F');
sig = gk_getSigTrialsSFTF(F,stim,2,3);
%sig = gk_getSigTrialsSF(spks,stim,2,3);

% identify tuned neurons
for neuron=1:size(iscell,1)
    for angle=1:4
        pON(neuron,angle)=anova1(squeeze(sig(angle).trials_ONresp(neuron,:,:)),[],"off");
        pOFF(neuron,angle)=anova1(squeeze(sig(angle).trials_OFFresp(neuron,:,:)),[],"off");
    end
end
pONmin=min(pON,[],2);
pOFFmin=min(pOFF,[],2);
isOnTuned=pONmin<0.0001;
onTunedIDs = find(isOnTuned);
isOffTuned=~isOnTuned & pOFFmin<0.0001;
offTunedIDs= find(isOffTuned);

% plot some neurons to see
for neuron=[onTunedIDs']%1:4556%[find(iscell(:,1)==1)']
    %neuron=21;
    for angle=1:4
        subplot(2,2,angle)
        plot(squeeze(mean(sig(angle).trials_dF_F(neuron,:,:,:),3))); hold on;
        xline([9 18])
        title(['Neuron: ' num2str(neuron) ' / Angle: ' num2str(angle)]);
    end
    pause(0.25);
    input('press enter to continue\n')
    clf
end

[~, si]= sort(pONmin(onTunedIDs));
[~, sio]= sort(pOFFmin(offTunedIDs));
% plot the tuning curves of tuned neurons
ni=0;
for n=onTunedIDs(si)'%onTunedIDs'
    ni=ni+1;
    s=mod(ni-1,100)+1;
    fi=ceil(ni/100);
    figure(fi);
    subplot(10,10,s); hold on;
    for angle=1:4
        plot(stim.Values, squeeze(mean(sig(angle).trials_ONresp(n,:,:),2))); ylim([-0.2 1.2]);
    end
end
