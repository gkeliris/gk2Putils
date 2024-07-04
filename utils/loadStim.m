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
            ds.cohort,ds.week,ds.mouseID,ds.expID)
        return
    end
else
    fprintf('%s, %s, %s, %s: stim.mat is not yet created\n',...
        ds.cohort,ds.week,ds.mouseID,ds.expID)
    return
end
