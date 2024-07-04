function sesPath = setSesPath(ds)
% USAGE: sesPath = setSesPath(ds)
%
% ds - the table returned by gk_datasetQuery
%
% Author: Georgios A. Keliris

ds = gk_selectDS(ds);
dataPath = setDataPath;
sesPath = fullfile(dataPath,'s2p_analysis',...
    ds.cohort,ds.mouseID,ds.week,ds.session,ds.expID);


