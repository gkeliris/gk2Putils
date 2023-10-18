function gk_plotLightArtifact(coh,wk,ms,ex)
% USAGE: gk_plotLightArtifact(coh,wk,ms,ex)
%
% Author: Georgios A. Keliris

pth=gk_getDESpath('proc',coh,wk,ms,ex);
load(fullfile(pth,'stimA.mat'));

plot(stimA.t,stimA.v,'b');