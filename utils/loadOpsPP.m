function opsPP = loadOpsPP(ds, plane)
% USAGE: opsPP = loadOpsPP(ds, [plane])
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
if isfile(fullfile(sesPath,'suite2p_orig',plane,'Fall.mat'))
    fprintf('Loading ops from Fall.mat... \n');
    load(fullfile(sesPath,'suite2p_orig',plane,'Fall.mat'), 'ops');
    opsPP=ops;
elseif ~isfile(fullfile(sesPath,'suite2p_orig',plane,'ops.npy'))
    error('.npy FILE NOT FOUND! Make sure dataset was preprocessed and try again.\n')
    return
else
    try
        fprintf('Loading stat from ops.npy via py.numpy.load...\n')
        ops_py = py.numpy.load(fullfile(sesPath,'suite2p_orig',plane,'ops.npy'),...
            pyargs('allow_pickle',true));
        ops_list = cell(ops_py.tolist());  % convert Python list to MATLAB cell array
        opsPP = cellfun(@(d) struct(d), ops_list);
    catch
        keyboard
    end
end


