function stimTimes = gk_getStimTimes(h5data, blockThr)
% USAGE: stimTimes = gk_getStimTimes(h5data, [blockThr])
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
if nargin<2
    blockThr=[10000 Inf 10000 Inf];
end

ChannelNames=h5data.chNames;
Num=[1:numel(ChannelNames)]';
T=table(Num,ChannelNames)
PD_channel=input("Enter the number of the photodiode channel: ");
try
    PD = eval(['h5data.' T.ChannelNames{PD_channel}]);
catch
    %PD = h5data.AI5;
    keyboard
end
% if reverse
%     
% end
h1=figure; hold on; plot(h5data.time,PD); xlabel('time [s]');
pause(0.001);
getreversal=true;
while getreversal
    reverse = input("Does the signal need reversal y/n [n]? ","s");
    if isempty(reverse) || reverse=='n'
        getreversal=false;
    elseif reverse=='y'
        getreversal=false;
        PD = max(PD) - PD;
        close(h1)
        h1=figure; hold on; plot(h5data.time,PD); xlabel('time [s]');
    else
        fprintf('please enter y or n\n')
    end
end

[tstartend] = input("If necessary enter start/end time in seconds [else press enter]. [tstart tend] = ");
if isempty(tstartend)
    tstart=h5data.time(1);
    tend=h5data.time(end);
else
    tstart=tstartend(1); 
    tend=tstartend(2);
end
t = h5data.time(h5data.time>=tstart & h5data.time<=tend);
photodiode= PD(h5data.time>=tstart & h5data.time<=tend);


% thr = input('Enter approximate threshold: ');
% close(h1)
% 
% h2=figure; hold on;
% histogram(photodiode,'BinMethod','integers','BinLimits',[thr-100 thr+100]); xline(thr,'r--')
% pause(0.001);
thr = input('Enter threshold (can be 1 or 2 values): ');
close(h1);
if numel(thr)==2
    thr1=max(thr);
    thr2=min(thr);
    stimON1=zeros(size(t));
    stimON2=zeros(size(t));
    stimON1(photodiode>thr1)=1;
    stimON2(photodiode<thr2)=1;
    [s1, blk_t1]=needsCleaning(stimON1,blockThr);
    if length(blockThr)<4
        blockThr(3)=blockThr(1);
        blockThr(4)=Inf;
    end
    [s2, blk_t2]=needsCleaning(stimON2,blockThr(3:4));
    stimTimes.onsets1  = t(diff(s1)==1);
    stimTimes.offsets1 = t(diff(s1)==-1);
    stimTimes.onsets2  = t(diff(s2)==1);
    stimTimes.offsets2 = t(diff(s2)==-1);
    
    stimTimes.onsets  = t(diff(s1)==1 | diff(s2)==1);
    stimTimes.offsets = t(diff(s1)==-1 | diff(s2)==-1);
    if ~isempty(blk_t1) %|| ~isempty(blk_t2)
        if ~isempty(blk_t2)
            blk_t=(blk_t1+blk_t2)/2;
        else
            blk_t=blk_t1;
        end
        blk_t=[0; blk_t; numel(stimTimes.onsets)];
        for b=1:numel(blk_t)-1
            stimTimes.block_trials{b}=blk_t(b)+1:blk_t(b+1);
        end
    end     
    s=s1+2*s2;
else
    stimON=zeros(size(t));
    if min(photodiode)<-1000
        stimON(photodiode<thr)=1;
    else
        stimON(photodiode>thr)=1;
    end
    [s, blk_t]=needsCleaning(stimON,blockThr);
    stimTimes.onsets  = t(diff(s)==1);
    stimTimes.offsets = t(diff(s)==-1);
    if ~isempty(blk_t)
        blk_t=[0; blk_t/2; numel(stimTimes.onsets)];
        for b=1:numel(blk_t)-1
            stimTimes.block_trials{b}=blk_t(b)+1:blk_t(b+1);
        end
    end
    
end
stimTimes.stim_continuous=s;
stimTimes.t=t;


h1=figure; hold on; plot(h5data.time,PD); xlabel('time [s]');
thr=max(thr);
plot(t,s/max(s)*150+thr,'m','LineWidth',1.5);
ylim([thr-100 thr+180])
pause(0.001)
answer = input("Check and press a key to continue ","s");
close(h1);
return

%%%% helper functions
function [s, blk_t]=needsCleaning(s,blockThr)

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
if length(blockThr) < 2
    blockThr(2) = Inf;
end
if find(delta>=blockThr(1) & delta<=blockThr(2)) %seconds => probably blocks
    blks = input("Does the experiment have blocks of presentation y/n [y]? ","s");
    if isempty(blks)
        blks='y';
    end
    if strcmp(blks,'y')
        blk_t=find(delta>=blockThr(1) & delta<=blockThr(2));
    else
        blk_t=[];
    end
else
    blk_t=[];
end
close(hc);


function [s, delta]=clean(s)

onoff=diff(s);
edg=find(abs(onoff));
delta=diff(edg);
for n=15:-1:1
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


