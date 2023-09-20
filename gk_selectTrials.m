function select = gk_selectTrials(xpr, stimValue, angle)

% if isstring(stimValue) && strcmp(upper(stimValue),'ALL')
%     loop

if exist('angle','var')
    ind = find(xpr.stimIDs==stimValue & xpr.stimAngles==angle);
else
    ind = find(xpr.stimIDs==stimValue);
end

select.t=xpr.t;
select.stim_dur=xpr.stim_dur;
select.trials = xpr.trials(:,:,ind);
select.trials_dF_F = xpr.trials_dF_F(:,:,ind);
select.trials_ONresp = xpr.trials_ONresp(:,ind);
