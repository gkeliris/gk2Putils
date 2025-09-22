function data = loadSuite2pBinary(ds, plane, start, stop)
% USAGE: data = loadSuite2pBinary(ds, plane, start, stop)
%
% Loads the data from a suite2p binary .bin files to a matlab 3D-array
%
% INPUTS:
%   ds      can be either a dataset table (returned by gk_datasetQuery) or
%           a full path to the file
%
%   plane   a number or the folder indicating which plane to load. In case 
%           ds is a fullpath then this is ignored
%
%   start   the image number from which to start loading (if not given will
%           start loading from image number 1
%
%   stop    the image number at which to stop loading (in not given will
%           load up to the last image
%
% OUTPUTS:
%   data    the 3D array (x,y,t)
%

% Author: Georgios A. Keliris

if ~isstr(ds)
    if isnumeric(plane)
        p=plane;
        plane=['plane', num2str(plane)];
    else
        p=str2num(plane(6:end));
    end
end


if isstr(ds)
    fid = fopen(ds,'r');
    try
        % try to load ops.npy from the same folder as ds
        d=dir(ds);
        np = py.importlib.import_module('numpy');
        ops = np.load('ops.npy', pyargs('allow_pickle',true));
        ops_dict=ops.item();
        Lx=double(ops_dict{'Lx'});
        Ly=double(ops_dict{'Ly'});
    catch
        keyboard
    end
else
    ops = loadOps(ds);
    fid = fopen(fullfile(ops.fast_disk,'suite2p',plane,'data.bin'),'r');
    Lx=ops.allLx(p+1);
    Ly=ops.allLy(p+1);
end



if exist('start')
    status = fseek(fid,(start-1)*2*Lx*Ly,'bof'); %int16 is 2 bytes
end
if exist('stop')
    data = fread(fid, (stop-start+1)*Lx*Ly,'*int16');
else
    data = fread(fid, '*int16');
end
data = reshape(data, Lx, Ly, []);
data = permute(data,[2 1 3]);
fclose(fid);

