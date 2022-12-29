function stimTimes = gk_getStimTimes(h5data)
% USAGE: stimTimes = gk_getStimTimes(h5data)
%
% Input: h5data (a structure returned by gk_readH5)
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

h1=figure; hold on; plot(h5data.t,h5data.AI4); xlabel('time [s]');
pause(0.001);
[tstartend] = input("If necessary enter start/end time in seconds [else press enter]. [tstart tend] = ");
if isempty(tstartend)
    tstart=h5data.t(1);
    tend=h5data.t(end);
else
    tstart=tstartend(1);
    tend=tstartend(2);
end
t = h5data.t(h5data.t>=tstart & h5data.t<=tend);
photodiode= h5data.AI4(h5data.t>=tstart & h5data.t<=tend);
thr = input('Enter threshold: ');
close(h1);

stimON=zeros(size(t));
stimON(photodiode>thr)=1;

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
        [s, delta]=clean(s);
    end
end
close(hc);
stimTimes.onsets  = t(diff(s)==1);
stimTimes.offsets = t(diff(s)==-1);

stimTimes.t=t;
stimTimes.stim_continuous=s;

%%%% helper function
function [s, delta]=clean(s)

onoff=diff(s(:));
edg=find(abs(onoff));
delta=diff(edg);
onsets = [edg(1); edg(find(delta>1000)+1)]+1;
offsets = [edg(find(delta>1000)); edg(end)];
for t=1:numel(onsets)
    s(onsets(t):offsets(t))=1;
end
onoff=diff(s);
edg=find(abs(onoff));
delta=diff(edg);

