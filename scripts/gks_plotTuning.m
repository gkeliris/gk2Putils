figure; hold on;
n=1;
c=xpr.onTunedIDs_allGrp(xpr.adjR2_cellSort(n));
g=xpr.grpOrder(xpr.adjR2_cellSort(n),:);
subplot(2,2,1);
gk_plot_tuning(xpr,c,g(1),xpr.stimValues);
subplot(2,2,2);
gk_plot_tuning(xpr,c,g(2),xpr.stimValues);
subplot(2,2,3);
gk_plot_tuning(xpr,c,g(3),xpr.stimValues);
subplot(2,2,4)
gk_plot_tuning(xpr,c,g(4),xpr.stimValues);

