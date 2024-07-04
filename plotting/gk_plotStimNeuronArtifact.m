function gk_plotStimNeuronArtifact(ds,roiNum)
% USAGE: gk_plotStimNeuronArtifact(ds,roiNum)
%
% INPUT: 
%   ds - the output of gk_datasetQuery
%   roiNum :  number (global suite2p roi index)
%
% Author: Georgios A. Keliris
ds = gk_selectDS(ds);
gk_plotStimulus(ds);
gk_plotLightArtifact(ds);
gk_plotROI(ds,'F',roiNum);