function roi = gk_getRoiTrials(xpr, roiCount)

Ntrials=numel(xpr.stimIDs);
roi.count=roiCount;
roi.origID=xpr.cellIDs(roiCount);
%roi.trials=squeeze(xpr.trials(roiCount,:,:));
roi.trials=cellfun(@(x) squeeze(x(roiCount,:,:)),xpr.sorted_trials,'UniformOutput',false);
%roi.trials_dF_F=squeeze(xpr.trials_dF_F(roiCount,:,:));
roi.trials_dF_F=cellfun(@(x) squeeze(x(roiCount,:,:)),xpr.sorted_trials_dF_F,'UniformOutput',false);
if ~isfield(xpr,'stimAngles')
    xpr.stimAngles=ones(size(xpr.stimIDs));
end
roi.responses=table(xpr.trials_ONresp(roiCount,:)',...
    xpr.stimIDs,xpr.stimAngles,'VariableNames',...
    {'ONresp','stimID','grpID'});
