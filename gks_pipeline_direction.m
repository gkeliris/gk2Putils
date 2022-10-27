% gks_pipeline

% go to folder with h5 file
h5 = gk_readH5('DR_M19_0003.h5');
stim.Times = gk_getStimTimes(h5);
stim.Times = gk_getTimeStamps2P(stim.Times);
stim.Times = gk_getStimFrameTimes(stim.Times);



% load the stimulus types and random sequence from the matlab files
load('D:\2 visual stimulus files\direction.mat')

stim.IDs=[Stims];
stim.IDs=stim.IDs(1:120); %DR3 M19
stim.Values=StimTyps;
% save this for easy access later
save('stim','stim');

% load a signal and split it to trials

%load('suite2p/combined/Fall.mat','spks');
load('stim.mat');
load('suite2p/combined/Fall.mat','iscell');
load('suite2p/combined/Fall.mat','F');
sig = gk_getSigTrialsCON(F,stim,2,3);

% identify tuned neurons
for neuron=1:size(iscell,1)
    pON(neuron)=anova1(squeeze(sig.trials_ONresp(neuron,:,:)),[],"off");
    pOFF(neuron)=anova1(squeeze(sig.trials_OFFresp(neuron,:,:)),[],"off");
end

isOnTuned=pON<0.01;
onTunedIDs = find(isOnTuned);
isOffTuned=~isOnTuned & pOFF<0.01;
offTunedIDs= find(isOffTuned);

% plot some neurons to see
for neuron=[onTunedIDs]%1:4556%[find(iscell(:,1)==1)']

    %subplot(2,2,angle)
    plot(squeeze(mean(sig.trials_dF_F(neuron,:,:,:),3))); hold on;
    xline([9 18])
    title(['Neuron: ' num2str(neuron)]);

    pause(0.25);
    input('press enter to continue\n')
    clf
end

[~, si]= sort(pON(onTunedIDs));
[~, sio]= sort(pOFF(offTunedIDs));
% plot the tuning curves of tuned neurons
ni=0;
for n=onTunedIDs(si)%onTunedIDs'
    ni=ni+1;
    s=mod(ni-1,100)+1;
    fi=ceil(ni/100);
    figure(fi);
    subplot(10,10,s); hold on;
    plot(stim.Values, squeeze(mean(sig.trials_ONresp(n,:,:),2))); ylim([-0.2 1.2]);
end
