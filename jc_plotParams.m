function jc_plotParams(ds,sigName,typeplot,angletype,weight,numbins, export)
% USAGE: jc_plotParams(ds,sigName,typeplot,angletype,weight,numbins, export)
%
% INPUT:
%   ds :        the output of gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   typeplot:   which type of plot ['boxplot','histogram]
%   angletype:  how to plot angles ['angle','together']
%   weight:     weight given to R2 vs max change in fluorescence, 1 just
%   change in fluorescence, 0 is just R2
%   numbins:    number of bins if chose histogram
%   export:     if you want to export if chose histogram, 1 = yes, 0 = no
%
%   example: jc_plotparams(ds,'F','histogram','angle',.5,10,1)
if nargin < 7
    export = 0; 
 elseif nargin < 6
     numbins = [];
     export = 0;
 end

if weight >1 || weight <0
    error("Make ratio a number between 0 and 1") 
end

ds = jc_selectmanyDS(ds);
file = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_params/';
temp = table;
for i = 1:height(ds)
    params_file_name = ['DS_',ds.cohort{i},'_',ds.week{i},'_', ds.mouseID{i},'_',...
        ds.expID{i},'_',ds.session{i},'_',sigName,'_CRF.xlsx'];
    temp = [temp ; readtable([file params_file_name])];
end
for j = 1:height(temp)
    table_col_names_temp = ["Rmax_0deg", "c50_0deg", "n_0deg","s_0deg","Rmax_90deg",...
            "c50_90deg", "n_90deg","s_90deg","Rmax_120deg", "c50_120deg", "n_120deg",...
            "s_120deg","Rmax_210deg", "c50_210deg", "n_210deg","s_210deg"];
    score = [(1-weight)*temp.R2_0deg(j)+weight*temp.MaxChange_0deg(j)...
        (1-weight)*temp.R2_90deg(j)+weight*temp.MaxChange_90deg(j)...
        (1-weight)*temp.R2_120deg(j)+weight*temp.MaxChange_120deg(j)...
        (1-weight)*temp.R2_210deg(j)+weight*temp.MaxChange_210deg(j)];
    [~, ind] = max(score);
    table_col_names_temp(4*(ind-1)+(1:4)) = [];
    for k = 1:length(table_col_names_temp)
        temp.(table_col_names_temp{k})(j) = NaN;
    end
end

table_col_names = ["Rmax_0deg", "c50_0deg", "n_0deg","s_0deg","Rmax_90deg",...
                    "c50_90deg", "n_90deg","s_90deg","Rmax_120deg", "c50_120deg", "n_120deg",...
                    "s_120deg","Rmax_210deg", "c50_210deg", "n_210deg","s_210deg"];
switch typeplot
    case 'boxplot'
        switch angletype
            case 'together'
                figure
                titles = ["Rmax", "c50", "n", "s"];
                col_nums = [0 1 2 3];
                for i = 1:4
                    subplot(2,2,i)
                    data = [temp.(table_col_names(1+col_nums(i))); temp.(table_col_names(5+col_nums(i)));...
                        temp.(table_col_names(9+col_nums(i))); temp.(table_col_names(13+col_nums(i)))];
                    boxplot(data);
                    title(titles(i));
                end
            case 'angle'
                figure
                titles = ["Rmax 0deg", "c50 0deg", "n 0deg","s 0deg","Rmax 90deg",...
                    "c50 90deg", "n 90deg","s 90deg","Rmax 120deg", "c50 120deg", "n 120deg",...
                    "s 120deg","Rmax 210deg", "c50 210deg", "n 210deg","s 210deg"];
                for i = 1:16
                    subplot(4,4,i)
                    data = temp.(table_col_names(i));
                    boxplot(data);
                    title(titles(i));
                end
        end
    case 'histogram'
        switch angletype
            case 'together'
                figure
                titles = ["Rmax", "c50", "n", "s"];
                col_nums = [0 1 2 3];
                for i = 1:4
                    subplot(2,2,i)
                    data = [temp.(table_col_names(1+col_nums(i))); temp.(table_col_names(5+col_nums(i)));...
                        temp.(table_col_names(9+col_nums(i))); temp.(table_col_names(13+col_nums(i)))];
                    histogram(data,numbins);
                    title(titles(i));
                end
                if export
                    bins = cell(1, 4);
                    edges = cell(1, 4);
                    titles = cell(1, 4);
                    hist_exportPath = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_histograms/';
                    hist_fileName = input('Please enter a name for the histogram file: ', 's');
                    hist_fileName = strcat(hist_fileName,'.xlsx');
                    for i = 1:4
                        subplot(2, 2, i);
                        h = findobj(gca, 'Type', 'histogram');
                        [bins{i}, edges{i}] = histcounts(h.Data,numbins);
                        titles{i} = get(get(gca, 'Title'), 'String');
                    end
                    bins = bins';
                    edges = edges';
                    titles = titles';
                    temp_histtable = table(titles, bins, edges, 'VariableNames', {'Title', 'Bins', 'Edges'});
                    fullFilePath = fullfile(hist_exportPath, hist_fileName);
                    writetable(temp_histtable, fullFilePath);
                end
            case 'angle'
                figure
                titles = ["Rmax 0deg", "c50 0deg", "n 0deg","s 0deg","Rmax 90deg",...
                    "c50 90deg", "n 90deg","s 90deg","Rmax 120deg", "c50 120deg", "n 120deg",...
                    "s 120deg","Rmax 210deg", "c50 210deg", "n 210deg","s 210deg"];
                for i = 1:16
                    subplot(4,4,i)
                    data = temp.(table_col_names(i));
                    histogram(data,numbins);
                    title(titles(i));
                end
                if export
                    bins = cell(1, 16);
                    edges = cell(1, 16);
                    titles = cell(1, 16);
                    hist_exportPath = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_histograms/';
                    hist_fileName = input('Please enter a name for the histogram file: ', 's');
                    hist_fileName = strcat(hist_fileName,'.xlsx');
                    for i = 1:16
                        subplot(4, 4, i);
                        h = findobj(gca, 'Type', 'histogram');
                        [bins{i}, edges{i}] = histcounts(h.Data,numbins);
                        titles{i} = get(get(gca, 'Title'), 'String');
                    end
                    bins = bins';
                    edges = edges';
                    titles = titles';
                    temp_histtable = table(titles, bins, edges, 'VariableNames', {'Title', 'Bins', 'Edges'});
                    fullFilePath = fullfile(hist_exportPath, hist_fileName);
                    writetable(temp_histtable, fullFilePath);
                end
        end 
end         




