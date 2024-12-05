% Analysis of coh1
ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh1');

for d=[2:5 7:9 12]
    ds(d,1:end-2)
    xpr = gk_getTunedROIs(ds(d,:), 'F',2, 3, 0.0001,0.7,true);
    xpr = gk_calc_tuning(xpr);
end

ds = gk_datasetQuery('week','w22','expID','contrast','cohort','coh1');

for d=[1:3 5:8 10:11]
    ds(d,1:end-2)
    xpr = gk_getTunedROIs(ds(d,:), 'F',2, 3, 0.0001,0.0,true);
    xpr = gk_calc_tuning(xpr);
end