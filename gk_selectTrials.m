function select = gk_selectTrials(xpr, stimIndex, angleIndex)
% USAGE: select = gk_selectTrials(xpr, [stimIndex], [angleIndex])
%
% INPUT:
%       xpr         - the output of gk_getTunedROIs
%       stimIndex   - the index of the stimulus (when not given a list will
%                     be printed and a selection should be made)
%       angleIndex  - the index of the angle (select when not given)
%
% OUTPUT:
%       select  - a structure containing the selected trials
%
% Author: Georgios A. Keliris

if nargin<2
    fprintf('The stim list is the following:\n')
    disp(table(unique(xpr.stimIDs), xpr.stimValues,'variableNames',{'stimIndex','stimValues'}))
    datID = input('Please select one Index: ','s');
    stimIndex = str2double(datID);
end
if nargin<3 && isfield(xpr,'stimAngles')
    fprintf('\nThe angle list is the following:\n')
    disp(table(unique(xpr.stimAngles), xpr.stimAnglesValues,'variableNames',{'angleIndex','angleValues'}))
    datID = input('Please select one Index: ','s');
    angleIndex = str2double(datID);
end


if exist('angleIndex','var')
    ind = find(xpr.stimIDs==stimIndex & xpr.stimAngles==angleIndex);
else
    ind = find(xpr.stimIDs==stimIndex);
end

select.t=xpr.t;
select.stim_dur=xpr.stim_dur;
select.trials = xpr.trials(:,:,ind);
select.trials_dF_F = xpr.trials_dF_F(:,:,ind);
select.trials_ONresp = xpr.trials_ONresp(:,ind);
