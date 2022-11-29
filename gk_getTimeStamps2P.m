function frame_t = gk_getTimeStamps2P(fpath, firstTiff)

if nargin<1
    [firstTiff, fpath] = uigetfile('*.tif','Select the first tiff segment');
end
[~, fname]=fileparts(firstTiff);
tiffSegments = dir(fullfile(fpath, [fname(1:end-4) '*.tif']));

tStart = tic;
fprintf('Beginning import of tall TIFF stacks.\n');

% assume TIFF labeling is "TITLE_EXPERIMENT_SEGMENT.tif"
nameParts = split(tiffSegments(1).name, '_');

% loop over all TIFFs
frame_t=[]; 
for i=1:length(tiffSegments)
    fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
    
    % Get header info and data from TIFFs
    % Method 1
% % %     frames = scanimage.util.getMroiFrameSequence(...
% % %         fullfile(tiffSegments(i).folder, tiffSegments(i).name));
% % %     ts = [frames(:).timestamp];
% % %     zValues=[frames(:).z];
% % %     zLevels=numel(unique(zValues));
% % %     if rem(numel(zValues),zLevels)
% % %         ts = [ts nan(1, zLevels-rem(numel(zValues),zLevels))];
% % %     end
    % Method 2 (not sure if this is faster but sometimes fails)
% % %     [~, ~, header] = scanimage.util.getMroiDataFromTiff(...
% % %         fullfile(tiffSegments(i).folder, tiffSegments(i).name));
% % %     nCh = header.SI.hChannels.channelsAvailable;
% % %     ts = header.frameTimestamps_sec(1:nCh:end);
% % %     zLevels = header.SI.hFastZ.numFramesPerVolume;
    % Method 3 (GAK fast script)
    [ts, z] = gk_getTimeStamps(...
        fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    ts = unique(ts);
    zLevels=numel(z{1});

    frame_t = [frame_t; ts];

    fprintf("\t\tcompleted at %.2f s.\n", toc(tStart));
end
frame_t = reshape(frame_t, [zLevels numel(frame_t)/zLevels]);
fprintf("Full completed in %.2f s.\n", toc(tStart));