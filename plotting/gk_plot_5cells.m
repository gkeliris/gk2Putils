function gk_plot_5cells(xpr, startCell)
% USAGE: gk_plot_5cells(xpr, startCell)

if nargin < 2
    startCell=1;
end

figure;
set(gcf, 'Position',  [0, 0, 800, 900])
for n=1:5
    ordN=n+startCell-1;
    c=xpr.onTunedIDs_allGrp(xpr.adjR2_cellSort(ordN));
    g=xpr.grpOrder(xpr.adjR2_cellSort(ordN),1);
    min_min=Inf;
    max_max=0;
    for i=1:numel(xpr.stimValues)
        ax(i)=subplot(14,5,(i-1)*5+n);
        resp=squeeze(xpr.sorted_trials_dF_F{i,g}(c,:,:))';
        imagesc(xpr.t,1:size(resp,1),resp);
        %ax(i+14)=subplot(2,15,i+15);
        %resp=squeeze(xpr.sorted_trials{i,g}(c,:,:))';
        %imagesc(xpr.t,1:size(resp,1),resp);
        xline(0); xline(xpr.stim_dur);
        axis off
        [tmp_min, tmp_max]=caxis(ax(i));
        min_min=min(min_min,tmp_min);
        max_max=max(max_max,tmp_max);
    end
    set(ax,'CLIM',[min_min, max_max]);
    clear ax
    pause(0.01)
end