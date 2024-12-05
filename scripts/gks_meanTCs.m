dim3=size(mTC_WT,3);
xpr.t=xpr.t(1:29);
figure; hold on;
sel=[4 5 6];
p = plot(xpr.t, squeeze(mean(mTC_WT(sel,:,:,1),3)));hold on;
for tr=sel%1:numel(xpr.stimValues)
    
    shadedErrorBar(xpr.t,squeeze(mean(mTC_WT(tr,:,:,1),3)),...
        squeeze(std(mTC_WT(tr,:,:,1),0,3))./sqrt(dim3),...
        'lineprops',{'Color', p(find(sel==tr)).Color}, 'transparent', 1);
end

dim3=size(mTC_TG,3);
xpr.t=xpr.t(1:29);
hold on;
for tr=sel%1:numel(xpr.stimValues)
    
    shadedErrorBar(xpr.t,squeeze(mean(mTC_TG(tr,:,:,1),3)),...
        squeeze(std(mTC_TG(tr,:,:,1),0,3))./sqrt(dim3),...
        'lineprops',{'Color', p(find(sel==tr)).Color}, 'transparent', 1);
end
plot(xpr.t, squeeze(mean(mTC_TG(sel,:,:,1),3)),'*');

xline(0,':','stim ON');
xline(xpr.stim_dur,':','stim OFF');
xlabel('time [s]');
ylabel('\DeltaF/F');
legend(num2str(xpr.stimValues(sel)));


%% 
figure; hold on;
maxIndex=find(xpr.t>0.5 & xpr.t<1.1);
sel=[1:9 11:14];
p = plot(xpr.stimValues(sel), [squeeze(mean(mTC_WT(sel,maxIndex,:,1),[2,3])),...
    squeeze(mean(mTC_TG(sel,maxIndex,:,1),[2,3]))]);
shadedErrorBar(xpr.stimValues(sel),squeeze(mean(mTC_WT(sel,maxIndex,:,1),[2,3])),...
        squeeze(std(mTC_WT(sel,maxIndex,:,1),0,[2,3]))./sqrt(dim3),...
        'lineprops',{'Color', p(1).Color}, 'transparent', 1);
shadedErrorBar(xpr.stimValues(sel),squeeze(mean(mTC_TG(sel,maxIndex,:,1),[2,3])),...
        squeeze(std(mTC_TG(sel,maxIndex,:,1),0,[2,3]))./sqrt(dim3),...
        'lineprops',{'Color', p(2).Color}, 'transparent', 1);
xlabel('Contrast [%]');
ylabel('mean \DeltaF/F');
legend('WT','MeCP2')
