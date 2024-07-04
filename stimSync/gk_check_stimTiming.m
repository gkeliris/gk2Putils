function stimTimes = gk_check_stimTiming(stimTimes, stimA, h5, dT)
% USAGE: stimTimes = gk_check_stimTiming(stimTimes, stimA, [h5], dT)
%
% INPUT: stimTimes - the stim.Times field
%        stimA - the stimA returned by gk_get_stimArtifact
%
% OUTPUT: The (optionally corrected) stim.Times field
% 
% Author: Georgios A. Keliris
% v.0.1 17 October 2022

if nargin==4
    fprintf('Note: mydT = %.2f has been applied\n',dT)
    tCorr=-1;
    stimTimes = correct(stimTimes, dT+tCorr);
else
    dT=0;
    tCorr=0;
end

answer='y';
while strcmp(answer,'y')

h = figure; hold on;
if nargin>=3
    try
        plot(h5.t+tCorr+dT,h5.AI4./25,'y');
    catch
        plot(h5.t+tCorr+dT,h5.Visual./25,'y');
    end
    xline(dT,'g')
end
plot(stimTimes.t,stimTimes.stim_continuous*2*median(stimA.v),'m');
plot(stimA.t,stimA.v,'k.-','LineWidth',1); xlim([stimA.t(1) stimA.t(end)]);

dt=median(diff(stimA.t));
title(['dt = ', num2str(median(diff(stimA.t)))]);
pause(0.1)

answer = input("Does the timing needs correction y/n [n]? ","s");
if isempty(answer)
    answer='n';
end
if strcmp(answer,'y')
    factor = input("Enter the correction factor in dt units: ");
    stimTimes = correct(stimTimes, factor*dt);
    if nargin==3
        h5.t=h5.t+factor*dt;
    end
end

try
    close(h)
catch
   % do nothing
end

end
return
%%%% helper 
function stimTimes = correct(stimTimes, factor)
stimTimes.t = stimTimes.t + factor;
stimTimes.onsets = stimTimes.onsets + factor;
stimTimes.offsets = stimTimes.offsets + factor;
stimTimes = gk_getStimFrameTimes(stimTimes);