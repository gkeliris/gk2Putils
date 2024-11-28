start_i=100; % you can plot differnt cells by changing the start_i
figure;
cellIds=xpr.adjR2_cellSort(start_i:start_i+19); % cells selected according to adjR2 sorting (see gk_sortFit)
for i=1:20
    ax(i)=subplot(4,5,i);
    cell=xpr.onTunedIDs_allGrp(cellIds(i));
    grp=xpr.grpOrder(cellIds(i),1);
    gk_plot_tuning(xpr, cell, grp, xpr.stimValues, 'direction [deg]');
end
% equalize the y-limits in all subplots
[~,n]=max(cellfun(@(x) x(2),ylim(ax))); set(ax,'YLIM',ylim(ax(n)))