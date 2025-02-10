function ds = gk_datasetQuery(varargin)
% USAGE: ds = gk_datasetQuery(varargin)
%
% INPUT: pairs of inputs:   'name',     'value'
%                           'cohort',   ['lrn1',..]
%                           'day',      ['d0','d1','d2',...]
%                           'mouseID',  ['M827',...]
%                           'session',  ['ses1', 'ses2',...]
%                           'expID',    ['Familiar','DR',...]
%           
% example:
% ds = gk_datasetQuery('day','d6','expID','Familiar','mouseID','M827')
%
% Author: Georgios A. Keliris

% set up name-value pairs for varargin.
for i = 1:2:length(varargin) % work for a list of name-value pairs
    if ischar(varargin{i}) % check if is character
        prm.(varargin{i}) = varargin{i+1}; % override or add parameters to structure.
    end
end
prm.make = 1;
use_strcmp=false;
% read the table from the CSV file
T = readtable(fullfile('/mnt/NAS_UserStorage/Mingyu/learning/2P imaging/','LRN2P_datasets.csv'),'TextType','string');

if ~isfield(prm, 'cohort')
    prm.cohort = unique(T.cohort);
elseif isempty(find(strcmp(unique(T.cohort),prm.cohort), 1))
    prm.cohort = 'NULL';
end
if ~isfield(prm, 'day')
    prm.week = unique(T.week);
end
if ~isfield(prm, 'mouseID')
    prm.mouseID = unique(T.mouseID);
elseif ~isempty(find(strcmp(unique(T.mouseID),prm.mouseID), 1))
    use_strcmp=1;
end
if ~isfield(prm, 'session')
    prm.session = unique(T.session);
end
if ~isfield(prm, 'expID')
    prm.expID = unique(T.expID);
else
    ex=prm.expID;
    prm.expID = {ex, [ex '1'], [ex '2'], [ex '3'], [ex '4'], [ex '5'], [ex '6']}';
end

if use_strcmp
    ds = T(contains(T.cohort,prm.cohort) & contains(T.day,prm.day) & ...
        strcmp(T.mouseID,prm.mouseID) & contains(T.session,prm.session) & ...
        contains(T.expID, prm.expID),:);
else
    ds = T(contains(T.cohort,prm.cohort) & contains(T.day,prm.day) & ...
    contains(T.mouseID,prm.mouseID) & contains(T.session,prm.session) & ...
    contains(T.expID, prm.expID),:);
end
