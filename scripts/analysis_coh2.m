% Analysis of coh1
ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh2');

3:4 6:8 10 12:15 18 22
for d=[22:22]
    ds(d,1:end-2)
    xpr = gk_getTunedROIs(ds(d,:), 'F',2, 3, 0.0001,0.7,true);
    xpr = gk_calc_tuning(xpr);
end

ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh2');
err_datasets=[]
for d=[2, 9,11, 19, 20:21]
    ds(d,1:end-2)
    try
    xpr = gk_getTunedROIs(ds(d,:), 'F',2, 3, 0.0001,0.7,true);
    xpr = gk_calc_tuning(xpr);
    catch
        err_datasets=[err_datasets d]
    end
end