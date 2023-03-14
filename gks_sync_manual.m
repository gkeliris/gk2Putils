clear
load stim.mat
load stimA.mat
stim.Times = gk_check_stimTiming(stim.Times, stimA);

save('stim','stim')