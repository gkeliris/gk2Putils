figure;
c=xpr.onTunedIDs_allGrp(xpr.adjR2_cellSort(10));
min_min=Inf;
max_max=0;
for i=1:24
    ax(i)=subplot(4,6,i);
    imagesc(xpr.t,1:20,squeeze(xpr.sorted_trials_dF_F{i}(c,:,:))');
    xline(0); xline(xpr.stim_dur)
    [tmp_min, tmp_max]=caxis(ax(i));
    min_min=min(min_min,tmp_min);
    max_max=max(max_max,tmp_max);
end
set(ax,'CLIM',[min_min, max_max])
