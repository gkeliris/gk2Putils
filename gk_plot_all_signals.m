function gk_plot_all_signals(stimTimes, stimA)
% USAGE: gk_plot_all_signals(stimTimes, stimA)
%
% INPUT: stimTimes - the stim.Times field
%        stimA - the stimA returned by gk_get_stimArtifact
%
% Author: Georgios A. Keliris
% v.0.1 13 January 2023

h = figure;
subplot(5,1,1); hold on;
plot(stimTimes.t,stimTimes.stim_continuous*max(stimA.v));
plot(stimA.t,stimA.v,'k.-','LineWidth',1); xlim([stimA.t(1) stimA.t(end)]);
title(['dt = ', num2str(median(diff(stimA.t)))]);
pause(0.1)

subplot(5,1,2);
plot(stimTimes.t, stimTimes.photodiode);
title('photodiode');
subplot(5,1,3);
plot(stimTimes.t, stimTimes.fidget);
title('fidget');
subplot(5,1,4);
plot(stimTimes.t, stimTimes.encoder1);
title('encoder1');
subplot(5,1,5);
plot(stimTimes.t, stimTimes.encoder2);
title('encoder2');

return