ds = gk_datasetQuery('week','w22','expID','contrast','cohort','coh1');
for i=[5:8]
    ds(i,:)
    xpr = gk_getTunedROIs(ds(i,:), 'F',2, 3, 0.0001);
    xpr = gk_calc_tuning(xpr);
end