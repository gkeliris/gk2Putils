
fpath=uigetdir('Pick the experiment directory');
cd(fpath);
h5file = uigetfile('*.h5','Pick the H5 file');
[p, fname, ext]=fileparts(h5file);
fname(end:end+1)='01';

fpath=uigetdir('Pick the experiment directory');
tiffSegments = dir(fullfile(fpath, [fname '_*.tif']));


tStart = tic;
fprintf('Beginning import of tall TIFF stacks.\n');



% assume TIFF labeling is "TITLE_EXPERIMENT_SEGMENT.tif"
nameParts = split(tiffSegments(1).name, '_');

% loop over all TIFFs, re-stitch each one, then concatenate full stack
stimA=[];
for i=1:length(tiffSegments)
    fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
    
    % Get header info from TIFFs
    %header = imfinfo(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    %imgHeight = header(1).Height;
    obj=scanimage.util.ScanImageTiffReader('SF_M19_00001_00001.tif');
    [frames] = scanimage.util.getMroiFrameSequence(fullfile(tiffSegments(i).folder, tiffSegments(i).name));

    % get relevant infomation for TIFF header from ScanImage
    %artist_info = header(1).Artist;

    % retrieve ScanImage ROIs information from json-encoded string 
    %artist_info = artist_info(1:find(artist_info == '}', 1, 'last'));
%     artist = jsondecode(artist_info);
%     hSIh = header(1).Software;
%     hSIh = regexp(splitlines(hSIh), ' = ', 'split');
%     for j=1:length(hSIh)
%         if strfind(hSIh{j}{1}, 'SI.hRoiManager.scanVolumeRate')
%             fs = str2double(hSIh{j}{2});
%         end
%         if strfind(hSIh{j}{1}, 'SI.hFastZ.userZs')
%             zs = str2num(hSIh{j}{2}(2:end-1));
%             nplanes = numel(zs);
%         end
% 
%     end

    %% get frames
    % import TIFF
    for j = 2:8:size(header, 1)
        tiffFrame = imread(fullfile(tiffSegments(i).folder, tiffSegments(i).name), j);
%         if i==1 & j==2
%             lowIntensity=find(tiffFrame<350);
%         end
%         stimA=[stimA; mean(tiffFrame(lowIntensity))];
        stimA=[stimA; mean(tiffFrame,[1 2])];

    end

   
    
    fprintf("\t\tcompleted at %.2f s.\n", toc(tStart));


end

fprintf("Plotting photodiode and stim Artefact\n");
h5=gk_readH5(h5file);
figure; hold on;
plot([1:length(h5.AI4)]/h5.fs,h5.AI4,'r');
plot(1/fs:1/fs:length(stimA)/fs,stimA,'b','Linewidth',2)




fprintf("Full completed in %.2f s.\n", toc(tStart));