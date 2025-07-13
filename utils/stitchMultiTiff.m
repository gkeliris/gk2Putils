function imagedata = stitchMultiTiff(pth,pattern,addOvl,save4Dmat)
% USAGE: imagedata = stitchMultiTiff(pth,pattern,[addOvl],[save4Dmat])
%
% addOvl : a two element vector [addDX, addDY] values to add to the overlap
%
% example: pth=pwd; data = loadMultiTiff(pth,'file*.tif', [15, 0]);

% NOTE: from visual inspection the overlap to be added to dx is ~15 pixels

tic
if nargin < 4
    save4Dmat = false;
end

if nargin < 3
    addOvl=[0, 0];
end

d=dir(fullfile(pth,pattern));
[~,~]=mkdir(pth,'stitched');

% now ops is returned by ovl (corrected by addOvl) so not used
% ops = gk_SI_tiffInfo(fullfile(d(1).folder,d(1).name));

% Read data of all TIFF files
imagedata = loadMultiTiff(pth,pattern);
% Check if nROIs have overlap to blend them (linearly)
fprintf('checking for ovelapping ROIs\n');
[ovl, ops] = getRoiOverlap(fullfile(d(1).folder,d(1).name), addOvl);
imagedata = stitchROIs(imagedata,ops,ovl);

% save the 4D stitched imagedata as a .mat file
if save4Dmat
    save stitched imagedata
end
% make the 4D to 3D to later store all frames similar to original
imagedata = reshape(imagedata,size(imagedata,1),size(imagedata,2),[]);

%% This is to save the stitched files frame by frame as the original
frame=1;
fprintf('frame done %05d/%05d (file 01)',frame,size(imagedata,3));
for i=1:numel(d)
    % Open the original TIFF file for reading
    tiffOriginal = Tiff(d(i).name, 'r');
    
    % Create a new TIFF file for writing
    tiffNew = Tiff(fullfile(d(i).folder,'stitched',['stx_', d(i).name]), 'w8');
    while true
        % Read all tags and image data from the current directory
        tags = getAllTags(tiffOriginal);  % Custom function to read all tags
        
        % Write the current page to the new TIFF file
        setAllTags(tiffNew, tags, imagedata);        % Custom function to set tags
        tiffNew.write(imagedata(:,:,frame));         % Write the image data
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%05d/%05d (file %02d)'...
            ,frame, size(imagedata,3), i);
        frame=frame+1;
        % Create a new page in the new file
        tiffNew.writeDirectory();
        % Break if end of tiffOriginal was reached
        if tiffOriginal.lastDirectory()
            break;
        end
        tiffOriginal.nextDirectory();
    end
     % Close both TIFF files
    tiffOriginal.close();
    tiffNew.close();
end
fprintf('\n');
toc
end

function tags = getAllTags(tiffObj)
% getAllTags - Reads all the tags from the current directory of a TIFF file
%
% tiffObj: A Tiff object open in read mode.
%
% Returns a struct containing all tag names and their values.

tagIDs = fieldnames(Tiff.TagID);  % Get all possible tag IDs
tags = struct();  % Initialize the tags structure

% Loop over all tag IDs and try to read each one
for i = 1:numel(tagIDs)
    try
        % Get the tag value if it's available
        tagValue = tiffObj.getTag(Tiff.TagID.(tagIDs{i}));
        tags.(tagIDs{i}) = tagValue;
    catch
        % If the tag cannot be read, just skip it
    end
end
end

function setAllTags(tiffObj, tags,imagedata)
% setAllTags - Sets all the tags for the current directory of a TIFF file
%
% tiffObj: A Tiff object open in write mode.
% tags: A struct containing tag names and their values.

tagNames = fieldnames(tags);  % Get all the tag names

% Loop over all tags and set each one
for i = 1:numel(tagNames)
    try
        % Set the tag value
        tiffObj.setTag(Tiff.TagID.(tagNames{i}), tags.(tagNames{i}));
    catch
        % If the tag cannot be set, skip it
    end
end
% Set essential tags that must be preserved
tiffObj.setTag('ImageWidth', size(imagedata,2));
tiffObj.setTag('ImageLength', size(imagedata,1));
tiffObj.setTag('RowsPerStrip', size(imagedata,1));
tiffObj.setTag('BitsPerSample', tags.BitsPerSample); % Ensures 16 bits per sample
tiffObj.setTag('SamplesPerPixel', tags.SamplesPerPixel);
tiffObj.setTag('Photometric', tags.Photometric);
tiffObj.setTag('Compression', tags.Compression);
tiffObj.setTag('PlanarConfiguration', tags.PlanarConfiguration);
tiffObj.setTag('SampleFormat', tags.SampleFormat);
end

function im = stitchROIs(data,ops,ovl)
fprintf('Stiching...\n');
data = single(reshape(data,size(data,1),size(data,2), ops.numSlices, ops.numVolumes));
% Get the max dimensions to be able to montage the stitched image
Sx=max(ops.dx+ops.allLx);
Sy=max(ops.dy+ops.allLy);
% Stitch the nROIs in a single 4D volume timeseries
im=single(NaN*zeros(Sy,Sx,ops.numSlices,ops.numVolumes));
for p=1:numel(ops.allLy)
    im(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:,:)=...
        data(ops.lines_from(p):ops.lines_to(p),:,:,:);
end

if ~isempty(find(cellfun(@isempty,ovl.stitched),1))
    for p=1:numel(ops.allLy)
        if p>1 && ~isempty(ovl.stitched{p-1,p})
            
            overlapFrom=min(ovl.perPlane{p-1,p});
            overlapTo=max(ovl.perPlane{p-1,p});
            
            wgt=repmat(linspace(0,1,overlapTo(1)-overlapFrom(1)+1),overlapTo(2)-overlapFrom(2)+1,1);
            if ops.dx(p-1)<ops.dx(p) % p-1 is to the left
                wgt=fliplr(wgt);
            end
            wgt=repmat(wgt,1,1,ops.numSlices,ops.numVolumes);
            
            overlap1=wgt.*data(ops.lines_from(p-1):ops.lines_to(p-1),...
                overlapFrom(1):overlapTo(1),:,:);
            
            overlapFrom=min(ovl.perPlane{p,p-1});
            overlapTo=max(ovl.perPlane{p,p-1});
            
            overlap2=fliplr(wgt).*data(ops.lines_from(p):ops.lines_to(p),...
                overlapFrom(1):overlapTo(1),:,:);
      
            overlapFrom=min(ovl.stitched{p-1,p});
            overlapTo=max(ovl.stitched{p-1,p});
            
            im(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1),:,:)=...
                overlap1 + overlap2;
            
        end
    end
end
im = int16(im);
end