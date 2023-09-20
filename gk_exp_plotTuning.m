function gk_exp_plotTuning(coh,wk,ms,ex,sigName,t_before,t_after,whichROI,pthr)

exportPath='/mnt/12TB_HDD_6/ThinkmateB_HDD6_Data/GKeliris/PPT_log';

xpr = gk_exp_getSigTrials(coh,wk,ms,ex,sigName,t_before,t_after);
xpr = gk_getTunedROIs(xpr,pthr);
if size(xpr.onTunedIDs_allGrp,1)==0
    fprintf('No tuned neurons, try with a relaxed statistical pThreshold\n');
    return
end
multiGrp=false;
export=false;
switch xpr.expType
    case 'contrast'
        xlabl='Contrast [%]';
        multiGrp=true;
    case 'OR'
        xlabl='orientation [deg]';
    case 'DR'
        xlabl='direction [deg]';
    case 'OO'
        xlabl='responses to black(0) or white(1)';
    case 'SF' 
        xlabl='SF [cycles/deg]';
        multiGrp=true;
    case 'TF'
        xlabl='TF [cycles/s]';
        multiGrp=true;
    otherwise
        xlabl='arbritrary units';
end

if isnumeric(whichROI)
    ROIs=whichROI;
else
    switch whichROI
        case 'sortedOnTuned'
            ROIs=[xpr.onTunedIDs_allGrp(xpr.sortedOnTunedIDs_allGrp)]';
        case 'export'
            ROIs=[xpr.onTunedIDs_allGrp(xpr.sortedOnTunedIDs_allGrp)]';
            export=true;

    end
end

n=0;
for roi=ROIs
    n=n+1;
    if multiGrp
        angles={'0','90','120','210'};

        for g=1:numel(xpr.grp)
            subplot(2,4,2*(g-1)+1);
            gk_plot_trials(xpr, roi, g, xpr.stimValues, false)
%             for stm=1:14
%                 %trialInd = find(xpr.stimIDs==stm & xpr.stimAngles==g);
%                 %select = gk_selectTrials(xpr, stm, g);
%                 
%             end
            title(['ROI#=', num2str(roi), ', angle=', angles{g}]);
            legend off
            subplot(2,4,2*g);
            gk_plot_tuning(xpr, roi, g, xpr.stimValues, xlabl)
            title(['ROI#=', num2str(roi), ', angle=', angles{g}]);
        end
       

    else
        g=1;

        subplot(1,2,1);
        gk_plot_trials(xpr.grp(g), roi, xpr.grp(g).stimValues, false)
        subplot(1,2,2);
        gk_plot_tuning(xpr.grp(g), roi, xpr.grp(g).stimValues, xlabl)

    end

    if ~export
        pause(0.05);
        input('press enter to continue or ctrl-c to exit\n')
        clf
    else
        if n==1
        set(gcf, 'Color', [1 1 1],'Position',[0 0 1400 1080])
        pptx = exportToPPTX();
        pptx.addSlide();
        pptx.addTextbox(sprintf('Dataset: %s, %s, %s, %s\nSignal Type: %s\n',coh,wk,ms,ex,sigName));
        pptx.addTextbox(sprintf('\n\n\nROIs (p < %f): N_tuned / N_total = %d / %d (%.1f %%)\n',...
            pthr,size(xpr.onTunedIDs_allGrp,1),size(xpr.isOnTuned_allGrp,1),...
            size(xpr.onTunedIDs_allGrp,1)/size(xpr.isOnTuned_allGrp,1)*100));
        end
        pptx.addSlide();
        pptx.addPicture(gcf);
    end

end
if export
    try
        pptx.save(fullfile(exportPath,['DS_',coh,'_',wk,'_',ms,'_',ex,'_',sigName]));
        close all
    catch ME
        display(getReport(ME))
        keyboard
    end
end

% %%%%
% % plot the tuning curves of tuned neurons
% ni=0;
% for n=onTunedIDs(si)'%onTunedIDs'
%     ni=ni+1;
%     s=mod(ni-1,100)+1;
%     fi=ceil(ni/100);
%     figure(fi);
%     subplot(10,10,s); hold on;
%     for angle=1:4
%         plot(stim.Values, squeeze(mean(sig(angle).trials_ONresp(n,:,:),2))); ylim([-0.2 1.2]);
%     end
% end






