function data = loadSuite2pBinary(ds, plane, chan, start, stop, forceRaw)
% USAGE: data = loadSuite2pBinary(ds, plane, chan, start, stop, forceRaw)
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
%   chan    1 (default) for channel 1 or 2 for channel 2
%
%   start   the image number from which to start loading (if not given will
%           start loading from image number 1
%
%   stop    the image number at which to stop loading (in not given will
%           load up to the last image
%
%   forceRaw forces the loading of the raw binary files
%
% OUTPUTS:
%   data    the 3D array (x,y,t)
%

% Author: Georgios A. Keliris


if isnumeric(plane)
    p=plane;
    plane=['plane', num2str(plane)];
else
    p=str2num(plane(6:end));
end

if nargin<3 || isempty(chan) || chan==1
    if exist("forceRaw","var") && forceRaw
        fileName='data_raw.bin';
    else
        fileName='data.bin';
    end
elseif chan==2
    if exist("forceRaw","var") && forceRaw
        fileName='data_chan2_raw.bin'
    else
        fileName='data_chan2.bin';
    end
else
    error('input "chan" should be either [] or 1 or 2')
end

   
if isstr(ds)
    fid = fopen(ds,'r')
else
    ops = loadOps(ds);
    fid = fopen(fullfile(ops.fast_disk,'suite2p',plane,fileName),'r');
end

%Lx=ops.allLx(p+1);
%Ly=ops.allLy(p+1);
Lx=ops.Lx;
Ly=ops.Ly;

if exist('start') & ~isempty(start)
    status = fseek(fid,(start-1)*2*Lx*Ly,'bof'); %int16 is 2 bytes
end
if exist('stop') & ~isempty(stop)
    data = fread(fid, (stop-start+1)*Lx*Ly,'*uint16');
else
    data = fread(fid, '*uint16');
end
data = reshape(data, Lx, Ly, []);
data = permute(data,[2 1 3]);
fclose(fid);

