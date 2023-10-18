function tc = gk_getCellTimecourse(coh,wk,ms,ex,roinums)
% USAGE: tc = gk_getCellTimecourse(coh,wk,ms,ex,[roinums])
%
% INPUT:
% roinums : 
%    can be a vector of numbers or a string -> 'cells' (default) or 'all'
%
% Author: Georgios A. Keliris

if nargin<5
    roinums='cells';
end

pth=gk_getDESpath('proc',coh,wk,ms,ex);
iscell=readNPY(fullfile(pth, 'suite2p/combined/iscell.npy'));
cellNums=find(iscell(:,1));
load(fullfile(pth,'stim'),'stim');
tc.t=stim.Times.frame_t(1,:);
F=readNPY(fullfile(pth,'suite2p/combined/F.npy'));

if ischar(roinums)
    if strcmpi(roinums,'cells')
        roinums=cellNums;
    elseif strcmpi(roinums,'all')
        roinums=1:size(F,1);
    end
end
noncells=find(~ismember(roinums,cellNums));
if ~isempty(noncells)
    fprintf('WARNING: ROI# %d not a cell\n',roinums(noncells))
end    
tc.v=F(roinums,:);
