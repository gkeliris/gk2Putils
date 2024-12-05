function gk_plot_contrast(xpr, ordCells)

if nargin < 2
    ordCells = 1:10;
end
ny=5;
nx=ceil(numel(ordCells)/ny);

figure;
for n=1:numel(ordCells)
    ordN=ordCells(n);
    c=xpr.onTunedIDs_allGrp(xpr.adjR2_cellSort(ordN));
    g=xpr.grpOrder(xpr.adjR2_cellSort(ordN),1);
    h=subplot(nx,ny,n);
    gk_plot_tuning(xpr,c,g,xpr.stimValues,'Contrast [%]')
    axis(h,'normal')
end