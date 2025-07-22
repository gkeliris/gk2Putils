function frameTimes = gk_getBrukerFrames(ds)
% USAGE: frameTimes = gk_getBrukerFrames(ds)
%
% 

d=dir(fullfile(ds.rawPath,'*.xml'));
d=d(~contains({d.name}, 'VoltageRecording'));
v2=xml2struct(fullfile(d.folder,d.name));
frameTimes = cell2mat(cellfun(@(x) str2double(x.Attributes.relativeTime), v2.PVScan.Sequence.Frame, 'UniformOutput', false));
