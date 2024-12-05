function sorted_meanTC = gk_plot_meanTunedCells(xpr)

allcell_meanTC = cellfun(@(x) squeeze(mean(x(:,:,:),3)'),xpr.sorted_trials_dF_F,'UniformOutput',false);
%allcell_semTC = cellfun(@(x) squeeze(std(x(:,:,:),0,3)'/size(x,3)),xpr.sorted_trials_dF_F,'UniformOutput',false);

tunedcell_meanTC = cellfun(@(x) x(:,xpr.onTunedIDs_allGrp),allcell_meanTC,'UniformOutput',false);
%tunedcell_semTC = cellfun(@(x) x(:,xpr.onTunedIDs_allGrp),allcell_semTC,'UniformOutput',false);


for s=1:numel(xpr.stimValues)
    [dim2, dim3]=size(tunedcell_meanTC{s,1});
    dim4 = size(tunedcell_meanTC,2);
    meanTC(s,:,:,:)=reshape([tunedcell_meanTC{s,:}],dim2,dim3,dim4);
    %semTC(s,:,:,:)=reshape([tunedcell_semTC{s,:}],dim2,dim3,dim4);
end
for c=1:size(meanTC,3)
    sorted_meanTC(:,:,c,:)=meanTC(:,:,c,xpr.grpOrder(c,:));
    %sorted_semTC(:,:,c,:)=semTC(:,:,c,xpr.grpOrder(c,:));
end

 figure; hold on;
 sel=[4, 8, 14];
 p = plot(xpr.t, squeeze(mean(sorted_meanTC(sel,:,:,1),3)));
 for tr=sel%1:numel(xpr.stimValues)
     
     shadedErrorBar(xpr.t,squeeze(mean(sorted_meanTC(tr,:,:,1),3)),...
         squeeze(std(sorted_meanTC(tr,:,:,1),0,3))./sqrt(dim3),...
         'lineprops',{'Color', p(find(sel==tr)).Color}, 'transparent', 1);
 end
xline(0,':','stim ON');
xline(xpr.stim_dur,':','stim OFF');
xlabel('time [s]');
ylabel('\DeltaF/F');
legend(num2str(xpr.stimValues(sel)));
title(xpr.mouse);
