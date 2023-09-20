function xpr = gk_sortAllTrials(xpr)

if isfield(xpr,'stimAngles')
    grps = unique(xpr.stimAngles);
    nGrps = numel(grps);
else
    grps = 1;
    nGrps = 1;
end



for g=1:nGrps
    for s=1:numel(xpr.stimValues)
        if nGrps>1
            ind = find(xpr.stimIDs==s & xpr.stimAngles==g);
        else
            ind = find(xpr.stimIDs==s);
        end
        

        xpr.sorted.trials{s,g} = xpr.trials(:,:,ind);
        xpr.sorted.trials_dF_F{s,g} = xpr.trials_dF_F(:,:,ind);
        xpr.sorted.trials_ONresp{s,g} = xpr.trials_ONresp(:,ind);
        
    end
end

