ds = gk_datasetQuery('session','ses1','mouseID','DS4', 'expID','contrast1','timepoint','T0')
gk_getStimulus(ds)

%xpr = gk_exp_getSigTrials(ds,'F',2,4,0,0.7);

xpr=gk_getTunedROIs(ds,'F',2,4,0.05,0.7,0,0);
