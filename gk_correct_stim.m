function stimTimes = gk_correct_stim(stimTimes, factor)
stimTimes.t = stimTimes.t + factor;
stimTimes.onsets = stimTimes.onsets + factor;
stimTimes.offsets = stimTimes.offsets + factor;
stimTimes = gk_getStimFrameTimes(stimTimes);