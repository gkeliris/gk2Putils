function swps = getSweeps(ds, reverse)
% USAGE: swps = getSweeps(ds, [reverse])
%
% INPUT: 
%   ds
%   reverse (optional): if the direction of the bar is to be reversed
%
% OUTPUT:
%   swps -> a structure containing info about the sweeps

% Author: Georgios A. Keliris
% v0.1 Apr 03, 2025


ds = gk_selectDS(ds);
if nargin<2
    if ~isempty(strfind(ds.expID,'barLR')) || ~isempty(strfind(ds.expID,'barBU'))
        reverse=false;
    elseif ~isempty(strfind(ds.expID,'barRL')) || ~isempty(strfind(ds.expID,'barUB'))
        reverse=true;
    else
        reverse=false;
    end
end

% load the timings to find onset and offset of stimulus
load(fullfile(setSesPath(ds),'matlabana','stim.mat'));


% Use timing to define the ISI interval durations to add frames at the end
% or beginning
%%%%%%%%%%%%%%%%%%%%%%%%
Delta=stim.Times.frame_onsets(2:end)-stim.Times.frame_offsets(1:end-1);
[counts, centers]=hist(Delta,1:max(Delta));
[~,ipks]=findpeaks(counts);
swps.interSweepFrames=centers(ipks(end));

endSweeps_ind=find(Delta>=ipks(end));
swps.endSweeps=[stim.Times.frame_offsets(endSweeps_ind) stim.Times.frame_offsets(end)];
swps.nSweeps=numel(swps.endSweeps);

swps.startSweeps(1)=stim.Times.frame_onsets(1);
for n=2:swps.nSweeps
    swps.startSweeps(n)=stim.Times.frame_onsets(endSweeps_ind(n-1)+1);
end
swps.sweepLength=swps.endSweeps'-swps.startSweeps';
swps.useSweepLength = min(swps.sweepLength);

if reverse
    % add intersweep interval at the start
    swps.start=stim.Times.frame_onsets(1)-swps.interSweepFrames;
    swps.stop=stim.Times.frame_offsets(end);
    swps.interStart(1)=swps.start;
    swps.interEnd(1)=swps.start+swps.interSweepFrames-1;
    swps.interStart(2:swps.nSweeps)=swps.endSweeps(1:end-1)+1;
    swps.interEnd(2:swps.nSweeps)=swps.startSweeps(2:end)-1;
else
    % add intersweep interval at the end
    swps.start=stim.Times.frame_onsets(1);
    swps.stop=stim.Times.frame_offsets(end)+swps.interSweepFrames;
    swps.interStart(1:swps.nSweeps-1)=swps.endSweeps(1:end-1)+1;
    swps.interEnd(1:swps.nSweeps-1)=swps.startSweeps(2:end)-1;
    swps.interStart(swps.nSweeps)=swps.stop-swps.interSweepFrames;
    swps.interEnd(swps.nSweeps)=swps.stop;
end

swps.startSweepsRelative=swps.startSweeps-swps.start+1;
swps.interIndices=[];
for n=1:swps.nSweeps
    swps.indices(:,n)=swps.startSweeps(n):swps.startSweeps(n)+swps.useSweepLength-1;
    swps.interIndices=[swps.interIndices swps.interStart(n):swps.interEnd(n)];
end
swps.allIndRelative=reshape(swps.indices,[],1)-swps.start+1;
swps.interIndRelative=swps.interIndices-swps.start+1;
%%%%%%%%%%%%%%%%%%%%%%%%%