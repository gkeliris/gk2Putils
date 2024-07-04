function tc = gk_getRoiTimecourse(ds,sigName,roinums,plane)
% USAGE: tc = gk_getRoiTimecourse(ds,sigName,[roinums],[plane])
%
% INPUT:
%   ds  :   the table returned by gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   [roinums] : default 'cells'
%       can be  a) vector of numbers (global suite2p roi index)
%               b) a string -> 'cells' (default) or 'all'
%   [plane] : 'combined' or 'plane0','plane1',... or 0,1,...
%
% OUTPUT:
%   tc - a structure with fields .t(1xtimepoints) and .v(Nxtimepoints)
%
% Author: Georgios A. Keliris

warn=true;
if nargin<3 || isempty(roinums)
    roinums='cells';
end
if nargin<4
    plane='combined';
end

ds = gk_selectDS(ds);
iscell=loadSig(ds,'iscell',plane);
cellNums=find(iscell(:,1));
stim=loadStim(ds);
tc.t=stim.Times.frame_t(1,:);
sig=loadSig(ds,sigName,plane);

if ischar(roinums)
    if strcmpi(roinums,'cells')
        roinums=cellNums;
    elseif strcmpi(roinums,'all')
        warn=false;
        roinums=1:size(sig,1);
    end
end
noncells=find(~ismember(roinums,cellNums));
if ~isempty(noncells) && warn
    fprintf('WARNING: ROI# %d not a cell\n',roinums(noncells))
end    
tc.v=sig(roinums,:);
