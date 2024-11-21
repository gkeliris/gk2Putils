function frameTimes = gk_getFrameTimes(h5data, nZplanes)
% USAGE: frameTimes = gk_getFrameTimes(h5data, nZplanes)
%
% Input: h5data (a structure returned by gk_readH5)
%
% Output: vector of frameTimes in [s]
%
% NOTE: it assumes triggers are in h5data.AI5
%
% Example: frameTimes = gk_getFrameTimes(gk_readH5('OR_M19_0001.h5'));
%
% Author: Georgios A. Keliris
% v.1.0 2024
ChannelNames=h5data.chNames;
Num=[1:numel(ChannelNames)]';
T=table(Num,ChannelNames)
PD_channel=input("Enter the image trigger channel: ");
try
    PD = eval(['h5data.' T.ChannelNames{PD_channel}]);
catch
    %PD = h5data.AI5;
    keyboard
end
if nargin<2
    nZplanes=input('Enter number of z-planes:');
end

PD=(median(PD)-PD)/median(PD);
[~, frameTimes]=findpeaks(single(PD),h5data.time);
frameTimes=frameTimes(1:nZplanes:end)';

return
