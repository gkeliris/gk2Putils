function stim = loadStim(ds)
% USAGE: stim = loadStim(ds)
%
% ds - the table returned by gk_datasetQuery
%
% Author: Georgios A. Keliris

ds = gk_selectDS(ds);
sesPath=setSesPath(ds);

if isfile(fullfile(sesPath,'matlabana','stim.mat'))
    load(fullfile(sesPath,'matlabana','stim.mat'));
    if ~isfield(stim,'IDs')
        fprintf('%s, %s, %s, %s: addStimulus info missing\n',...
            ds.cohort,ds.day,ds.mouseID,ds.expID)
        return
    end
else
    try
        mkdir(fullfile(sesPath,'matlabana'));
        copyfile(fullfile(append(ds.rawPath,'_processed'),'stim.mat'),...
            fullfile(sesPath,'matlabana','stim.mat'));
        copyfile(fullfile(append(ds.rawPath,'_processed'),'stimA.mat'),...
            fullfile(sesPath,'matlabana','stimA.mat'));
        copyfile(fullfile(append(ds.rawPath,'_processed'),'stim_t.mat'),...
            fullfile(sesPath,'matlabana','stim_t.mat'));
        copyfile(fullfile(append(ds.rawPath,'_processed'),'frame_t.mat'),...
            fullfile(sesPath,'matlabana','frame_t.mat'));
        fprintf('copied the files...\n');
        load(fullfile(sesPath,'matlabana','stim.mat'));
    catch    
        fprintf('%s, %s, %s, %s: stim.mat is not yet created\n',...
            ds.cohort,ds.day,ds.mouseID,ds.expID)
        return
    end
end
