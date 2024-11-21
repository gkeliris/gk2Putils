w22ds = gk_datasetQuery('week','w22','expID','contrast','cohort','coh3');
tgds = jc_selectmanyDS(w22ds); % M418, M419, M420


params=table;
for d = 1 : size(tgds,1)
    xpr = gk_getTunedROIs(tgds(d,:), 'F',2, 3, 0.0001);
    
    nTuned = numel(xpr.tunedGlobalIDs);
    
    angles=repmat(xpr.stimAnglesValues',nTuned,1);
    angles_grpOrder = angles(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    C50 = cellfun(@(x) x.f.C50, xpr.tuning_params);
    C50_grpOrder = C50(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    Rmax = cellfun(@(x) x.f.Rmax, xpr.tuning_params);
    Rmax_grpOrder = Rmax(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    n = cellfun(@(x) x.f.n, xpr.tuning_params);
    n_grpOrder = n(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    s = cellfun(@(x) x.f.s, xpr.tuning_params);
    s_grpOrder = s(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    maxResp = cellfun(@(x) x.maxResp, xpr.tuning_params);
    maxResp_grpOrder = maxResp(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    prm_tmp = table(repmat(xpr.mouse,nTuned,1),[1:nTuned]',xpr.onTunedIDs_allGrp, xpr.tunedGlobalIDs, ...
        angles_grpOrder, C50_grpOrder, Rmax_grpOrder, n_grpOrder, s_grpOrder, maxResp_grpOrder,...
        'VariableNames',{'mouseID', 'tunedNum','cellNum','roiNum','angle','C50','Rmax','n','s', 'maxResp'});
    prm_tmp=prm_tmp(xpr.adjR2_cellSort,:);
    prm_tmp.rSquared = xpr.adjR2_sorted;
    params=[params; prm_tmp];
end
prmsTG = params;
%%
wtds = jc_selectmanyDS(w22ds); % M416, M417, M422, M453
params=table;
for d = 1 : size(wtds,1)
    xpr = gk_getTunedROIs(wtds(d,:), 'F',2, 3, 0.0001);
    
    nTuned = numel(xpr.tunedGlobalIDs);
    
    angles=repmat(xpr.stimAnglesValues',nTuned,1);
    angles_grpOrder = angles(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    C50 = cellfun(@(x) x.f.C50, xpr.tuning_params);
    C50_grpOrder = C50(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    Rmax = cellfun(@(x) x.f.Rmax, xpr.tuning_params);
    Rmax_grpOrder = Rmax(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    n = cellfun(@(x) x.f.n, xpr.tuning_params);
    n_grpOrder = n(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    s = cellfun(@(x) x.f.s, xpr.tuning_params);
    s_grpOrder = s(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    maxResp = cellfun(@(x) x.maxResp, xpr.tuning_params);
    maxResp_grpOrder = maxResp(bsxfun(@plus,(xpr.grpOrder-1)*nTuned,(1:nTuned)'));
    
    prm_tmp = table(repmat(xpr.mouse,nTuned,1),[1:nTuned]',xpr.onTunedIDs_allGrp, xpr.tunedGlobalIDs, ...
        angles_grpOrder, C50_grpOrder, Rmax_grpOrder, n_grpOrder, s_grpOrder, maxResp_grpOrder,...
        'VariableNames',{'mouseID', 'tunedNum','cellNum','roiNum','angle','C50','Rmax','n','s', 'maxResp'});
    prm_tmp=prm_tmp(xpr.adjR2_cellSort,:);
    prm_tmp.rSquared = xpr.adjR2_sorted;
    params=[params; prm_tmp];
end
prmsWT = params;

