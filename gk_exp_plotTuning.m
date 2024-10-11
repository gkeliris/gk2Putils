function gk_exp_plotTuning(ds,sigName,t_before,t_after,whichROI,pthr)
% USAGE: gk_exp_plotTuning(ds,sigName,t_before,t_after,whichROI,pthr)
%
% INPUT:
%   ds :        the output of gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   t_before:   seconds before stim onset
%   t_after:    seconds after stim offset
%   whichROI:   a) numeric: the ROI number(s) (suite2p ROI index - global)
%               b) string: 'export' => exports to PPT
%                          'sortedOnTuned' plots sorted according to p-val
%   pthr:       p-value to choose as threshold for tuned ROIs
%
%   calls -> gk_getTunedROIs, gk_plot_tuning, gk_plot_trials
%
% Author: Georgios A. Keliris
%
% See also gk_getTunedROIs, gk_plot_tuning, gk_plot_trials

exportPath = setExportPath;
ds = gk_selectDS(ds);
xpr = gk_getTunedROIs(ds,sigName,t_before,t_after,pthr);

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
    for wi=1:numel(whichROI)
        ROIs(wi)=find(xpr.cellIDs==whichROI(wi));
    end
else
    switch whichROI
        case 'sortedOnTuned'
            ROIs=[xpr.onTunedIDs_allGrp(xpr.sortedOnTunedIDs_allGrp)]';
        case 'export'
            ROIs=[xpr.onTunedIDs_allGrp(xpr.sortedOnTunedIDs_allGrp)]';
            export=true;

    end
end
if multiGrp
    table_col_names = {'ROI','Rmax_0deg', 'c50_0deg', 'n_0deg','s_0deg','R2_0deg','MaxChange_0deg',...
        'Rmax_90deg', 'c50_90deg', 'n_90deg','s_90deg','R2_90deg','MaxChange_90deg','Rmax_120deg',...
        'c50_120deg', 'n_120deg', 's_120deg','R2_120deg','MaxChange_120deg','Rmax_210deg', 'c50_210deg',...
        'n_210deg', 's_210deg','R2_210deg','MaxChange_210deg'};
    table_col_type = {'double','double','double','double','double','double','double','double',...
        'double','double','double','double','double','double','double','double','double',...
        'double','double','double','double','double','double','double','double'};
     params_table = table('Size', [numel(ROIs) numel(table_col_names)],'VariableTypes',...
         table_col_type,'VariableNames',table_col_names);
end  
n=0;
for roi=ROIs
    n=n+1;
    if multiGrp
        angles={'0','90','120','210'};
        params_table.ROI(n) = xpr.cellIDs(roi);
        for g=1:numel(xpr.grp)
            %subplot(2,4,2*(g-1)+1);
            subplot(2,4,g);
            if numel(whichROI)==1
                gk_plot_trials(xpr, roi, g, xpr.stimValues, true)
            else
                gk_plot_trials(xpr, roi, g, xpr.stimValues, false)
            end
            ylim([-0.5 3])
            title(['ROI#=', num2str(xpr.cellIDs(roi)), ', angle=', angles{g}]);
            legend off
            %subplot(2,4,2*g);
            h = subplot(2,4,4+g);
            cla(h)
            params = gk_plot_tuning(xpr, roi, g, xpr.stimValues, xlabl);
            params_table{n, table_col_names((g-1)*6 + (2:7))} = params;
            ylim([-0.2 2.8])
            title(['ROI#=', num2str(xpr.cellIDs(roi)), ', angle=', angles{g}]);
        end
       

    else
        g=1;
        subplot(1,2,1);
        gk_plot_trials(xpr, roi, g, xpr.stimValues, false)
        subplot(1,2,2);
        gk_plot_tuning(xpr, roi, g, xpr.stimValues, xlabl)

    end
    
    if numel(whichROI)==1
        return
    elseif ~export
        pause(0.05);
        input('press enter to continue or ctrl-c to exit\n')
        if n<numel(ROIs)
            clf
        end
    else
        if n==1
        set(gcf, 'Color', [1 1 1],'Position',[0 0 1200 900])
        pptx = exportToPPTX();
        pptx.addSlide();
        pptx.addTextbox(sprintf('Dataset: %s, %s, %s, %s\nSignal Type: %s\n',...
            ds.cohort,ds.week,ds.mouseID,ds.expID,sigName));
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
        pptx.save(fullfile(exportPath,['DS_',ds.cohort{1},'_',ds.week{1},'_',...
            ds.mouseID{1},'_',ds.session{1},'_',ds.expID{1},'_',sigName,'_',datestr(now, 'dd-mm-yyyy')]));
        close all
    catch ME
        display(getReport(ME))
        keyboard
    end
    %This is to save params table to excel 
    params_exportPath = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_params/';
    params_file_name = ['DS_',ds.cohort{1},'_',ds.week{1},'_', ds.mouseID{1},'_',...
        ds.expID{1},'_',ds.session{1},'_',sigName,'_CRF_',datestr(now,'dd-mm-yyyy'),'.xlsx'];
    fullPath = fullfile(params_exportPath, params_file_name);
    writetable(params_table, fullPath);
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






