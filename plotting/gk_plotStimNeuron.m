function gk_plotStimNeuron(ds,roiNum,plane)
% USAGE: gk_plotStimNeuron(ds,roiNum,[plane])
%
% INPUT: 
%   ds - the output of gk_datasetQuery
%   roiNum :  number (global suite2p roi index)
%
% Author: Georgios A. Keliris
if nargin<3
    plane='combined';
end
ds = gk_selectDS(ds);
gk_plotStimulus(ds,'hsv');
gk_plotROI(ds,'F',roiNum,plane);