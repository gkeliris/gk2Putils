function gk_plotLightArtifact(ds)
% USAGE: gk_plotLightArtifact(ds)
%
% Author: Georgios A. Keliris

stimA = loadStimArtifact(ds);
plot(stimA.t,stimA.v,'b');