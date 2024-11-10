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

if nargin<2
    nZplanes=input('Enter number of z-planes:');
end

PD=(median(h5data.AI5)-h5data.AI5)/median(h5data.AI5);
[~, frameTimes]=findpeaks(single(PD),h5data.t);
frameTimes=frameTimes(1:nZplanes:end)';

return
