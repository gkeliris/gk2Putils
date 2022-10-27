function stimTimes = gk_getTimeStamps2P(stimTimes)

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
stimTimes.frame_t=[]; %repmat({[]},ops.nplanes,1);
for i=1:length(tiffSegments)
    fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
    
    % Get header info and data from TIFFs
    % Method 1
    frames = scanimage.util.getMroiFrameSequence(...
        fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    ts = [frames(:).timestamp];
    zValues=[frames(:).z];
    zLevels=numel(unique(zValues));
    if rem(numel(zValues),zLevels)
        ts = [ts nan(1, zLevels-rem(numel(zValues),zLevels))];
    end
    % Method 2 (not sure if this is faster but sometimes fails)
% % %     [~, ~, header] = scanimage.util.getMroiDataFromTiff(...
% % %         fullfile(tiffSegments(i).folder, tiffSegments(i).name));
% % %     nCh = header.SI.hChannels.channelsAvailable;
% % %     ts = header.frameTimestamps_sec(1:nCh:end);
% % %     zLevels = header.SI.hFastZ.numFramesPerVolume;

    stimTimes.frame_t = [stimTimes.frame_t reshape(ts, [zLevels numel(ts)/zLevels])];

    fprintf("\t\tcompleted at %.2f s.\n", toc(tStart));
end

fprintf("Full completed in %.2f s.\n", toc(tStart));