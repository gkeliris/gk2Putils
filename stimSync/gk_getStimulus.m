function gk_getStimulus(ds)

ds = gk_selectDS(ds);
d=dir(fullfile(ds.rawPath,'*.h5'));
h5=gk_readH5(fullfile(ds.rawPath,d.name));
stim_t = gk_getStimTimes(h5);
save(fullfile(setSesPath(ds),'matlabana','stim_t'),'stim_t');
frame_t = gk_getFrameTimes(h5, gk_getNumPlanes(ds));
save(fullfile(setSesPath(ds),'matlabana','frame_t'),'frame_t');
stim.Times = gk_getStimFrameTimes(stim_t,frame_t);

d=dir(fullfile(setSesPath(ds),'matlabana','Contrast*.mat'));
load(fullfile(d.folder,d.name),'Stims','StimTypes','angles');
stim.expType='contrast';
stim.IDs=Stims(:,1);
stim.Angles=Stims(:,2);
StimTyps=StimTypes;
stim.Values=StimTyps;
stim.AnglesValues=angles;
Ntrials = size(stim.Times.frame_onsets,2);
Ntrials_equal = Ntrials - rem(Ntrials,numel(stim.Values));
if Ntrials>numel(stim.IDs)
    stim.IDs=[stim.IDs; stim.IDs];
end
stim.IDs=stim.IDs(1:Ntrials_equal);
save(fullfile(setSesPath(ds),'matlabana','stim'),'stim');

% stimA = gk_get_stimArtifact(ds.rawPath, ds.firstTiff)
% save(fullfile(setSesPath(ds),'matlabana','stimA'),'stimA');
return
