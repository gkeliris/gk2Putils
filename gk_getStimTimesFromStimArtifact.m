function stimTimes = gk_getStimTimesFromStimArtifact(stimA, fs)
% USAGE: stimTimes = gk_getStimTimesFromStimArtifact(stimA, fs)
%
% Input: stimA (a vector returned by gks_stim_artifact)
%        fs    (a constant returned by gks_stim_artifact) 
%
% Output: structure stimTimes with subfields .onsets and .offsets in [s]
%
% Instructions: The function first plots the photodiode signal and asks if
% it has to be limited in time (sometimes towards the end there is noise).
% If so then enter the tend in seconds. Further analysis will not consider
% time after that. It also asks for a first approximate threshold. To find
% out zoom in the figure to see what a reasonable value is. The function
% will then plot a histogram of values around the threshold to help you
% define a better threshold. Subsequently, the function will use that
% threshold to plot a stimulus continuous line (ON=1, OFF=0) and a
% histogram with the inter-stimulusSwitch-intervals. Those should normally
% be clustered around the stim on duration and the inter stimulus interval
% durations. If there is noise other values will be also present in the
% histogram. The function will ask if the stimulus needs cleaning. Press
% enter or type 'y' and repeat until you only see the values clustered
% around the two expected interals as above. Then press 'n' to finish.
%
% Example: stim = gk_getStimTimes(gk_readH5('OR_M19_0001.h5'));
%
% Author: Georgios A. Keliris
% v.1.0 - 19 Sep 2022

%absStimA=abs(stimA-median(stimA));
h1=figure; hold on; plot([1:length(stimA)]./fs,stimA); xlabel('time [s]');
pause(0.001);
thr = input('Enter approximate threshold: ');
close(h1);

h2=figure; hold on;
histogram(stimA,'BinMethod','integers','BinLimits',[thr-100 thr+100]); xline(thr,'r--')
pause(0.001);
thr = input('Enter threshold: ');
close(h2);
stimON=zeros(size(stimA));
stimON(stimA>thr)=1;

s=stimON;
onoff=diff(s);
edg=find(abs(onoff));
delta=diff(edg);
hc=figure;
answer='y';
while strcmp(answer,'y')
    figure(hc);
    subplot(2,1,1);
    plot(s,'m'); ylim([-1 2])
    subplot(2,1,2);
    histogram(delta,'BinMethod','integers')
    pause(0.01)
    answer = input("Does the stimulus needs cleaning y/n [y]? ","s");
    if isempty(answer)
        answer='y';
    end
    if strcmp(answer,'y')
        [s delta]=clean(s);
    end
end
close(hc);
stimTimes.t=[1:length(stimA)]./fs;
stimTimes.onsets  = stimTimes.t(find(diff(s)==1));
stimTimes.offsets = stimTimes.t(find(diff(s)==-1));
stimTimes.frame_onsets  = find(diff(s)==1);
stimTimes.frame_offsets = find(diff(s)==-1);
stimdur=median(stimTimes.frame_offsets-stimTimes.frame_onsets);
stimTimes.median_frame_duration=stimdur;
stimTimes.frame_offsets = stimTimes.frame_onsets+stimdur;
stimTimes.offsets = stimTimes.frame_offsets./fs;
stimTimes.frame_fs=fs;
stimTimes.stim_continuous=s;

%%%% helper function
function [s, delta]=clean(s)

onoff=diff(s);
edg=find(abs(onoff));
delta=diff(edg);
for n=2:-1:1
    dn=find(delta==n);
    for i=1:n
        s(edg(dn)+n)=s(edg(dn));
    end
    onoff=diff(s);
    edg=find(abs(onoff));
    delta=diff(edg);
end
d1=find(delta==1);
while d1
    s(edg(d1)+1)=s(edg(d1));
    onoff=diff(s);
    edg=find(abs(onoff));
    delta=diff(edg);
    d1=find(delta==1);
end


