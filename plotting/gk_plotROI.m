function gk_plotROI(ds,sigName,roiNum,plane)
% USAGE: gk_plotROI(ds,sigName,roiNum,[plane])
%
% INPUT:
%   ds  :   the table returned by gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   roiNum :  number (global suite2p roi index)
%   [plane] : 'combined' or 'plane0','plane1',... or 0,1,...
%
% Author: Georgios A. Keliris
if nargin<4
    plane='combined';
end
tc = gk_getRoiTimecourse(ds,sigName,roiNum,plane);
plot(tc.t,tc.v(1:numel(tc.t)),'k');