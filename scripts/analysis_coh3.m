% Analysis of coh3 (Stavroula)
ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh1');

for d=4:8
    ds(d,1:end-2)
    xpr = gk_getTunedROIs(ds(d,:), 'F',2, 3, 0.0001,0.0,true);
    %xpr = gk_calc_tuning(xpr);
end