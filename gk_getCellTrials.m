function roi = gk_getCellTrials(xpr, cellNum)
% USAGE: roi = gk_getCellTrials(xpr, cellNum)
%
% INPUT:
%       xpr - a structure returned by gk_exp_getSigTrials/gk_getTunedROIs
%       cellNum - the number of the cell (not global ROI) in xpr
%
% OUTPUT:
%       roi - a structure that contains the trials and responses of the cell
%
% Author: Georgios A. Keliris

%Ntrials=numel(xpr.stimIDs);
roi.count=cellNum;
roi.origID=xpr.cellIDs(cellNum);
%roi.trials=squeeze(xpr.trials(roiCount,:,:));
roi.trials=cellfun(@(x) squeeze(x(cellNum,:,:)),xpr.sorted_trials,'UniformOutput',false);
%roi.trials_dF_F=squeeze(xpr.trials_dF_F(roiCount,:,:));
roi.trials_dF_F=cellfun(@(x) squeeze(x(cellNum,:,:)),xpr.sorted_trials_dF_F,'UniformOutput',false);
if ~isfield(xpr,'stimAngles')
    xpr.stimAngles=ones(size(xpr.stimIDs));
end
roi.responses=table(xpr.trials_ONresp(cellNum,:)',...
    xpr.stimIDs,xpr.stimAngles,'VariableNames',...
    {'ONresp','stimID','grpID'});
