function data = gk_readH5(filename)
% USAGE: data = gk_readH5(filename)
%
% Function to read basic information such as photodiode, duration, sampling
% frequency from the H5 files.
%
% Input: H5 filename (e.g. [path OR_M19_0001.h5]);
%
% Output: a structure with information and signals
%
% Author: Georgios A. Keliris
% v1.0 - 18 Sep 2022 


%read some info from the header
data.duration    =h5read(filename,'/header/SweepDuration');
data.fs          =h5read(filename,'/header/AcquisitionSampleRate');
data.chNames     =h5read(filename,'/header/AIChannelNames');
try
    data.tStamp      =h5read(filename,'/sweep_0001/timestamp');
    sweeps           =h5read(filename,'/sweep_0001/analogScans');
catch
    try
    data.tStamp      =h5read(filename,'/sweep_0002/timestamp');
    sweeps           =h5read(filename,'/sweep_0002/analogScans');
    catch
        data.tStamp      =h5read(filename,'/sweep_0003/timestamp');
        sweeps           =h5read(filename,'/sweep_0003/analogScans');
    end
end     
data.time           = ([1/data.fs:1/data.fs:data.duration]+0)'; %add 0 seconds

if numel(data.time) ~= length(sweeps)
    data.time = ([1/data.fs:1/data.fs:length(sweeps)/data.fs]+0)';
    fprintf("WARNING: H5 duration and sweep points don't match!!\n")
    fprintf('Extracted the time using the sweep # of points.\n')
end
data.(data.chNames{1})=sweeps(:,1);
for i=1:numel(data.chNames)
    data.(strtrim(data.chNames{i}))=sweeps(:,i);
end

