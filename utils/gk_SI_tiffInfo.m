function [SI, ts] = gk_SI_tiffInfo(tif_file)
% USAGE: [SI, [ts]] = gk_SI_tiffInfo(tif_file)
%
% Function to return the header info
%
% INPUTS:
%    tif_file -> the file name or ds
%
% OUTPUTS:
%    SI -> a structure that contains the info
%    ts (optional) -> if requested contains the timestamps of the frames
%

% Author: Georgios A. Keliris
% v.0.1 Apr 06, 2025

if istable(tif_file)
    ds=gk_selectDS(tif_file);
    tif_file=fullfile(ds.rawPath,ds.firstTiff);
end
% define these because they are used in header (otherwise it crashes on eval)
scanimage.types.BeamAdjustTypes.LUT=[];
scanimage.types.BeamAdjustTypes.None=[];

% read the header
header = imfinfo(tif_file);
% Use eval to define the SI fields for the first frame
T=evalc(header(1).Software);

% retrieve ScanImage ROIs information from json-encoded string
artist_info = header(1).Artist;
artist_info = artist_info(1:find(artist_info == '}', 1, 'last'));
artist = jsondecode(artist_info);
SI.rois = artist.RoiGroups.imagingRoiGroup.rois;

% Unpack some important parameters
try SI.scanVolumeRate = SI.hRoiManager.scanVolumeRate; end
try SI.scanFrameRate = SI.hRoiManager.scanFrameRate; end
try SI.linePeriod = SI.hRoiManager.linePeriod; end
try SI.zs = SI.hStackManager.zsRelative; end
try SI.numVolumes = SI.hStackManager.numVolumes; end
try SI.numSlices = SI.hStackManager.numSlices; end
try SI.nChannels = numel(SI.hChannels.channelSave); end
try SI.flytoTimePerScanfield = SI.hScan2D.flytoTimePerScanfield; end

% Get some info for each ROI
SI.nrois=sum(arrayfun(@(x) size(x.zs,1),SI.rois)); %add up all rois. eg. some rois may have 2 planes only, some may have 3 planes.
SI.allLy = [];
SI.allLx = [];
SI.centerXYdeg = [];
SI.sizeXYdeg = [];
for k = 1:SI.nrois
	SI.allLy(k,1) = SI.rois(k).scanfields(1).pixelResolutionXY(2); % vertical pixels
	SI.allLx(k,1) = SI.rois(k).scanfields(1).pixelResolutionXY(1); % horizontal pixels
	SI.centerXYdeg(k, [2 1]) = SI.rois(k).scanfields(1).centerXY; % center coordinates of the ROI in degree angle
	SI.sizeXYdeg(k, [2 1]) = SI.rois(k).scanfields(1).sizeXY;  % size of the ROI in degree angle
end
SI.sizeXYum = SI.sizeXYdeg * SI.objectiveResolution; % size in micrometers
tmp = SI.centerXYdeg-SI.sizeXYdeg/2;
SI.dx = round((tmp(:,2)-min(tmp(:,2))).*SI.allLx./SI.sizeXYdeg(:,2));
SI.dy = round((tmp(:,1)-min(tmp(:,1))).*SI.allLy./SI.sizeXYdeg(:,1));
SI.n_flyback=round(SI.flytoTimePerScanfield/SI.linePeriod);
irow = [0 cumsum(SI.allLy'+SI.n_flyback)];
SI.lines_from=irow(1:end-1)+1;
SI.lines_to=irow(1:end-1)+SI.allLy';

% Extract frame TIMESTAMPS if requested
if nargout>1
    hdr={header(:).ImageDescription};
    pat='_sec = (?<t>\d+\.\d+\s)';
    res=regexp(hdr,pat,'names');
    a=cell2mat(res);
    ts=str2num([a.t]);
end







    

