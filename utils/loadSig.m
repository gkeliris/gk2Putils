function sig = loadSig(ds, sigName, plane)
% USAGE: sig = loadSig(ds, sigName, [plane])
%
% INPUT:
%   ds          - table returned by gk_datasetQuery
%   sigName     - 'F','Fneu', 'spks', 'iscell',...
%   plane       - default: 'combined', 'plane0', 'plane1',..., or  0, 1
%
% Author: Georgios A. Keliris

if nargin<3
    plane='combined';
end

if isnumeric(plane)
    plane=['plane', num2str(plane)];
end

sesPath = setSesPath(ds);
if ~isfile(fullfile(sesPath,'suite2p_orig',plane,[sigName,'.npy']))
    error('.npy FILE NOT FOUND! Make sure dataset was preprocessed and try again.\n')
    return
end
sig = readNPY(fullfile(sesPath,'suite2p_orig',plane,[sigName,'.npy']));


