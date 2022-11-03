function [ts, z, roi] = gk_getTimeStamps(tif_file)

header = imfinfo(tif_file);
hdr={header(:).ImageDescription};
pat='_sec = (?<t>\d+\.\d+\s)';
res=regexp(hdr,pat,'names');
a=cell2mat(res);
ts=str2num([a.t]);

artist_info     = header(1).Artist;
% retrieve ScanImage ROIs information from json-encoded string 
artist_info = artist_info(1:find(artist_info == '}', 1, 'last'));
artist = jsondecode(artist_info);
roi = artist.RoiGroups.imagingRoiGroup.rois;

z={roi.zs};

