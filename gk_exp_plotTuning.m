function gk_exp_plotTuning(coh,wk,ms,ex,sigName,t_before,t_after)

xpr = gk_exp_getSigTrials('coh1','w22','M117','OR','F',2,3);
xpr = gk_getTunedROIs(xpr,0.001);

% plot some neurons to see
for roi=[xpr.onTunedIDs(xpr.sortedOnTunedIDs)]
    subplot(1,2,1);
    gk_plot_trials(xpr, roi, xpr.stimValues, true)
    subplot(1,2,2);
    gk_plot_tuning(xpr, roi, xpr.stimValues, 'orientation [deg]')
    pause(0.25);
    input('press enter to continue or ctrl-c to exit\n')
    clf
end