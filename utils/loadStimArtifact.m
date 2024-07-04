function stimA = loadStimArtifact(ds)
% USAGE: stimA = loadStimArtifact(ds)
%
% ds - the table returned by gk_datasetQuery
%
% Author: Georgios A. Keliris

ds = gk_selectDS(ds);
sesPath=setSesPath(ds);

if isfile(fullfile(sesPath,'matlabana','stimA.mat'))
    load(fullfile(sesPath,'matlabana','stimA.mat'));
else
    fprintf('%s, %s, %s, %s: stimA.mat is not yet created\n',...
        ds.cohort,ds.week,ds.mouseID,ds.expID)
    return
end
