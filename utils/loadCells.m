function iscell = loadCells(ds, plane)
% USAGE: iscell = loadCells(ds, [plane])
%
% INPUT:
%   ds          - table returned by gk_datasetQuery
%   plane       - default: 'combined', 'plane0', 'plane1',..., or  0, 1
%
% Author: Georgios A. Keliris

if nargin<2
    plane='combined';
end

if isnumeric(plane)
    plane=['plane', num2str(plane)];
end

sesPath = setSesPath(ds);
if ~isfile(fullfile(sesPath,'suite2p_orig',plane,['iscell.npy']))
    error('.npy FILE NOT FOUND! Make sure dataset was preprocessed and try again.\n')
    return
end
iscell = readNPY(fullfile(sesPath,'suite2p_orig',plane,['iscell.npy']));


