function nPlanes = gk_getNumPlanes(tif_file)
% Function to return the timestamps and roi z levels
%
% USAGE: nPlanes = gk_getNumPlanes(tif_file)
% 
% INPUT: tif_file - the (full) path to the .tif file
%                   or a ds (returned by gk_datasetQuery)
%
% OUTPUT: nPlanes - a scalar number of planes
if istable(tif_file)
    try
        ops = loadOps(tif_file);
        nPlanes = ops.num_scanning_depths;
        return
    catch
        ds=gk_selectDS(tif_file);
        tif_file=fullfile(ds.rawPath,ds.firstTiff);
    end
end

header = imfinfo(tif_file);
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
nPlanes=numel(z);    
end


