function ops = loadOps(ds)
% USAGE: ops = loadOps(ds)
%
% INPUT:
%   ds          - table returned by gk_datasetQuery
%
% Author: Georgios A. Keliris


sesPath = setSesPath(ds);
if ~isfile(fullfile(sesPath,'ops_orig.mat'))
    error('.npy FILE NOT FOUND! Use mkops.py in pythong and try again.\n')
    return
end
load(fullfile(sesPath,'ops_orig.mat'))


