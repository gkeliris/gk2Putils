function stimA = gk_get_stimArtifact(fpath, firstTiff, whichSegments)
% USAGE: stimA = gk_get_stimArtifact(fpath, firstTiff, whichSegments)
%
if nargin<3
    whichSegments=1;
end
if nargin<1
    [firstTiff, fpath] = uigetfile('*.tif','Select the first tiff segment');
end
[~, fname]=fileparts(firstTiff);
tiffSegments = dir(fullfile(fpath, [fname(1:end-4) '*.tif']));
if isstr(whichSegments)
    whichSegments=1:length(tiffSegments);
end

tStart = tic;
fprintf('Beginning import of tall TIFF stacks.\n');
% assume TIFF labeling is "TITLE_EXPERIMENT_SEGMENT.tif"
nameParts = split(tiffSegments(1).name, '_');

% loop over all TIFFs
stimA.v=[]; stimA.t=[];
for i=[whichSegments] %1:length(tiffSegments)
    fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
    
    try 
        obj=scanimage.util.ScanImageTiffReader(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
        dat=data(obj);
    catch
        info=imfinfo(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
        dat=zeros(info(1).Height,info(1).Width,numel(info));
        for fi=1:numel(info)
            dat(:,:,fi)=imread(fullfile(tiffSegments(i).folder, tiffSegments(i).name), fi);
        end
    end
    [ts, zL] = gk_getTimeStamps(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    nCh=numel(ts)/numel(unique(ts));
    nZ=numel(zL{1});

    stimA.v=[stimA.v; squeeze(mean(dat(:,:,nCh:nCh*nZ:end),[1 2]))];
    stimA.t=[stimA.t; ts(nCh:nCh*nZ:end)];
end

fprintf("Full completed in %.2f s.\n", toc(tStart));