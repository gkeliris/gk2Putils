
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
stimA=[]; t=[];
for i=1:length(tiffSegments)
    fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
    
    % Get header info and data from TIFFs
    frames = scanimage.util.getMroiFrameSequence(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    obj=scanimage.util.ScanImageTiffReader(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    dat=data(obj);
    stimA=[stimA; squeeze(mean(dat(:,:,2:8:end),[1 2]))];
    t = [t; [frames(1:4:end).timestamp]'];
 
    fprintf("\t\tcompleted at %.2f s.\n", toc(tStart));
end

fprintf("Plotting photodiode and stim Artefact\n");
h5=gk_readH5(h5file);
figure; hold on;
plot([1:length(h5.AI4)]/h5.fs+1,h5.AI4,'r');
plot(t,stimA+600,'b','Linewidth',2)




fprintf("Full completed in %.2f s.\n", toc(tStart));