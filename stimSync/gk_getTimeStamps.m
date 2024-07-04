function [ts, z, roi] = gk_getTimeStamps(tif_file)
% Function to return the timestamps and roi z levels
%
% USAGE: [ts, z, roi] = gk_getTimeStamps(tif_file)
% 
% INPUT: tif_file - the (full) path to the .tif file
%
% OUTPUT: ts - a vector with the timestamps
%         z - 
header = imfinfo(tif_file);
hdr={header(:).ImageDescription};
pat='_sec = (?<t>\d+\.\d+\s)';
res=regexp(hdr,pat,'names');
a=cell2mat(res);
ts=str2num([a.t]);

if nargout>1
    sw = header(1).Software;
    try
        pat2='SI.hStackManager.zs = [(?<z>\d+( |]))+';
        res2=regexp(sw,pat2,'names');
        z=unique(str2num(res2.z(1:end-1)));
    catch
        pat2='SI.hStackManager.zs = (?<z>\d)';
        res2=regexp(sw,pat2,'names');
        z=str2num(res2.z);
    end
    
end
if nargout>2
    artist_info     = header(1).Artist;
    % retrieve ScanImage ROIs information from json-encoded string
    artist_info = artist_info(1:find(artist_info == '}', 1, 'last'));
    artist = jsondecode(artist_info);
    roi = artist.RoiGroups.imagingRoiGroup.rois;

end

