function [stimA, datOut] = gk_get_stimArtifact

%basePath = pwd;
%fpath=uigetdir('Pick the RAW tiff directory');
%cd(fpath);
[firstTiff, fpath] = uigetfile('*.tif','Select the first tiff segment');
[~, fname]=fileparts(firstTiff);
tiffSegments = dir(fullfile(fpath, [fname(1:end-2) '*.tif']));
%cd(basePath)

tStart = tic;
fprintf('Beginning import of tall TIFF stacks.\n');

% assume TIFF labeling is "TITLE_EXPERIMENT_SEGMENT.tif"
nameParts = split(tiffSegments(1).name, '_');

% loop over all TIFFs
stimA=[]; datOut=[];%repmat({[]},ops.nplanes,1);
for i=1:length(tiffSegments)
    fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
    
    % Get header info and data from TIFFs
    %frames = scanimage.util.getMroiFrameSequence(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    obj=scanimage.util.ScanImageTiffReader(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    dat=data(obj);
    datOut=cat(3,datOut,dat);
    stimA=[stimA; squeeze(mean(dat(:,:,2:8:end),[1 2]))];
%     for plane=1:ops.nplanes
%         stimTimes.frame_t{plane} = [stimTimes.frame_t{plane}; [frames(plane:ops.nplanes:end).timestamp]'];
%     end
    fprintf("\t\tcompleted at %.2f s.\n", toc(tStart));
end

fprintf("Full completed in %.2f s.\n", toc(tStart));