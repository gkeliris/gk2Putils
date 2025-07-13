function gk_getStimulus(ds)
% USAGE: gk_getStimulus(ds)
%
% this function will create and save the stim.mat file in matlabana folder
% NOTE: for this to work, image triggers should be in the .h5 file
%
% input: ds (output of gk_datasetQuery)

% Author: Georgios A. Keliris
% November 2024 

ds = gk_selectDS(ds);
if strcmp(ds.expID{1}(1:3),'bar')
    blockThr=1500;
else
    blockThr=10000;
end
d=dir(fullfile(ds.rawPath,'*.h5'));
h5=gk_readH5(fullfile(ds.rawPath,d.name));
stim_t = gk_getStimTimes(h5, blockThr);
if ~isfolder(fullfile(setSesPath(ds),'matlabana'))
    mkdir(fullfile(setSesPath(ds),'matlabana'));
end
save(fullfile(setSesPath(ds),'matlabana','stim_t'),'stim_t');
%load(fullfile(setSesPath(ds),'matlabana','stim_t'),'stim_t');

frame_t = gk_getFrameTimes(h5, gk_getNumPlanes(ds));
save(fullfile(setSesPath(ds),'matlabana','frame_t'),'frame_t');
stim.Times = gk_getStimFrameTimes(stim_t,frame_t);
%save(fullfile(setSesPath(ds),'matlabana','stim'),'stim');

stim.expType=ds.expID;

if strcmp(ds.expID{1}(1:2),'DR')
    load(fullfile(ds.matfolder,ds.matfile),'blockseq_DR15');
    [stim.Values,~,stim.IDs]=unique(blockseq_DR15);
elseif strcmp(ds.expID{1}(1:3),'bar')
    stim.Values=stim.Times.block_trials{1};
    stim.IDs=repmat(stim.Values,1, numel(stim.Times.block_trials))';
elseif strcmp(ds.expID{1}(1:6),'FamNov')
    load(fullfile(ds.matfolder,ds.matfile),'angles','angles1',...
        'reversals','blocks','blocks_id');
    stim.Values=[angles, angles1];
    stim.IDs=[];
    for b=1:blocks
        stim.IDs=[stim.IDs; ones(reversals,1)*blocks_id(b)];
    end
    
elseif strcmp(ds.expID{1}(1:8),'Familiar')
    load(fullfile(ds.matfolder,ds.matfile),'angles','reversals','blocks');
    stim.Values=angles;
    stim.IDs=ones(reversals*blocks,1);
    
end

    
% d=dir(fullfile(setSesPath(ds),'matlabana','Contrast*.mat'));
% load(fullfile(d.folder,d.name),'Stims','StimTypes','angles');
% stim.expType='contrast';
% stim.IDs=Stims(:,1);
% stim.Angles=Stims(:,2);
% StimTyps=StimTypes;
% stim.Values=StimTyps;
% stim.AnglesValues=angles;
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
