function data = gk_directLoadTiffs(ds, pattern)
% USAGE: data = gk_directLoadTiffs(ds, [pattern])
%
% INPUT: ds -> either the table returned by gk_datasetQuery or
%              the fullpath to the first tif-file
%
%       pattern -> a string that can identify the files, (default: '*.tif')
%
% OUTPUT: data -> a struct with two fields: info (similar to ops info) and
%               planes (a cell with the data per plane)
%
% Author: GAK, July 2025
if nargin < 1
    [p,fld]=uigetfile('*_00001.tif');
    ds=fullfile(fld,p);
end

if nargin < 2
    pattern='*.tif';
end
if istable(ds)
    ds=gk_selectDS(ds);
    ds=fullfile(ds.rawPath,ds.firstTiff);
end
[datapath,~,~] = fileparts(ds);

data.info = gk_SI_tiffInfo(ds);
dat = loadMultiTiff(datapath, pattern);

nplanes=numel(data.info.lines_from);
if nplanes>1
    fprintf('Splitting to %d planes...\n', nplanes)
    for np=1:nplanes
        data.planes{np}=...
            dat(data.info.lines_from(np):data.info.lines_to(np),:,:);
    end
else
    data.planes{1}=dat;
end



