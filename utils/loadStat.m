function stat = loadStat(ds, plane)
% USAGE: stat = loadStat(ds, [plane])
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
    fprintf('Loading stat from Fall.mat... \n');
    load(fullfile(sesPath,'suite2p_orig',plane,'Fall.mat'), 'stat');
elseif ~isfile(fullfile(sesPath,'suite2p_orig',plane,'stat.npy'))
    error('.npy FILE NOT FOUND! Make sure dataset was preprocessed and try again.\n')
    return
else
    try
        fprintf('Loading stat from stat.npy via py.numpy.load...\n')
        stat_py = py.numpy.load(fullfile(sesPath,'suite2p_orig',plane,'stat.npy'),...
            pyargs('allow_pickle',true));
        stat_list = cell(stat_py.tolist());  % convert Python list to MATLAB cell array
        stat = cellfun(@(d) struct(d), stat_list);
    catch
        keyboard
    end
end


