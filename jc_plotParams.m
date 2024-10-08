function output_table = jc_plotParams(ds,sigName,typeplot,angletype,weight, export, numbins)
% USAGE: jc_plotParams(ds,sigName,typeplot,angletype,weight,numbins, export)
%
% INPUT:
%   ds :        the output of gk_datasetQuery
%   sigName:    which signal ['F','Fneu','spks']
%   typeplot:   which type of plot ['boxplot','histogram,'cumulative']
%   angletype:  how to plot angles ['angle','together']
%   weight:     weight given to R2 vs max change in fluorescence, 1 just
%   change in fluorescence, 0 is just R2
%   export:     if you want to export if chose histogram, 1 = yes, 0 = no
%   numbins:    number of bins if chose histogram, choose 0 if you want to 
%               choose the edges yourself. The default is 10
%   output_table: Table which sorts by best angle for each ROI
%   example: jc_plotparams(ds,'F','histogram','angle',.5,10,1)
if nargin < 7
    numbins = 10; 
 elseif nargin < 6
     numbins = [];
     export = 0;
end



if weight >1 || weight <0
    error("Make ratio a number between 0 and 1") 
end

ds = jc_selectmanyDS(ds);
file = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_params/';
temp_plot = table;
temp_outtable = table;
for i = 1:height(ds)
    params_file_name = jc_selectDSdate(file,ds(i,:),sigName);
    
    temp_plot = [temp_plot ; readtable([file params_file_name])];
    temp_outtable = [temp_outtable ; readtable([file params_file_name])];
end
for j = 1:height(temp_plot)
    table_col_names_temp = ["Rmax_0deg", "c50_0deg", "n_0deg","s_0deg","Rmax_90deg",...
            "c50_90deg", "n_90deg","s_90deg","Rmax_120deg", "c50_120deg", "n_120deg",...
            "s_120deg","Rmax_210deg", "c50_210deg", "n_210deg","s_210deg"];
    score = [(1-weight)*temp_plot.R2_0deg(j)+weight*temp_plot.MaxChange_0deg(j)...
        (1-weight)*temp_plot.R2_90deg(j)+weight*temp_plot.MaxChange_90deg(j)...
        (1-weight)*temp_plot.R2_120deg(j)+weight*temp_plot.MaxChange_120deg(j)...
        (1-weight)*temp_plot.R2_210deg(j)+weight*temp_plot.MaxChange_210deg(j)];
    [~, ind] = max(score);
    table_col_names_temp(4*(ind-1)+(1:4)) = [];
    for k = 1:length(table_col_names_temp)
        temp_plot.(table_col_names_temp{k})(j) = NaN;
    end
end
output_col_names = ["Angle1", "Score1", "Angle2","Score2", "Angle3",...
    "Score3","Angle4","Score4","Weight"];
output_var_types = ["double","double","double", "double","double","double","double","double","double"];
output_table = table('Size',[height(temp_outtable),length(output_col_names)],...
    'VariableTypes',output_var_types,'VariableNames',output_col_names);
angles = [0 90 120 210];
for j = 1:height(temp_outtable)
    score = [(1-weight)*temp_outtable.R2_0deg(j)+weight*temp_outtable.MaxChange_0deg(j)...
        (1-weight)*temp_outtable.R2_90deg(j)+weight*temp_outtable.MaxChange_90deg(j)...
        (1-weight)*temp_outtable.R2_120deg(j)+weight*temp_outtable.MaxChange_120deg(j)...
        (1-weight)*temp_outtable.R2_210deg(j)+weight*temp_outtable.MaxChange_210deg(j)];
    
    [~, ranking] = sort(score, 'descend');
    
    for i = 1:4
        output_table.(output_col_names{2*i-1})(j) = angles(ranking(i));
        output_table.(output_col_names{2*i})(j) = score(ranking(i));
    end
    output_table.Weight(j) = weight;
end
if nargout == 0
    output_table = [];
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
                    data = [temp_plot.(table_col_names(1+col_nums(i))); temp_plot.(table_col_names(5+col_nums(i)));...
                        temp_plot.(table_col_names(9+col_nums(i))); temp_plot.(table_col_names(13+col_nums(i)))];
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
                    data = temp_plot.(table_col_names(i));
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
                    data = [temp_plot.(table_col_names(1+col_nums(i))); temp_plot.(table_col_names(5+col_nums(i)));...
                        temp_plot.(table_col_names(9+col_nums(i))); temp_plot.(table_col_names(13+col_nums(i)))];
                    if numbins == 0
                        prompt = sprintf('Please Enter the Edges for %s,the min and max are %f and %f: ',...
                            titles(i), min(data), max(data));
                        numbins = input(prompt);
                    end
                    histogram(data,numbins);
                    if numel(numbins) > 1
                        numbins = 0;
                    end
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
                    data = temp_plot.(table_col_names(i));
                    if numbins == 0
                        prompt = sprintf('Please Enter the Edges for %s,the min and max are %f and %f: ',...
                            titles(i), min(data), max(data));
                        numbins = input(prompt);
                    end
                    histogram(data,numbins);
                    if numel(numbins) > 1
                        numbins = 0;
                    end
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
    case 'cumulative'
        switch angletype
            case 'together'
                figure
                titles = ["Rmax", "c50", "n", "s"];
                col_nums = [0 1 2 3];
                for i = 1:4
                    subplot(2,2,i)
                    data = [temp_plot.(table_col_names(1+col_nums(i))); temp_plot.(table_col_names(5+col_nums(i)));...
                        temp_plot.(table_col_names(9+col_nums(i))); temp_plot.(table_col_names(13+col_nums(i)))];
                    cdfplot(data);
                    title(titles(i));
                    xlabel(titles(i));
                end
                if export
                    cumu_data = cell(4, 2); 
                    cumu_titles = cell(4, 1);
                    cumu_exportPath = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_cumulative/';
                    cumu_fileName = input('Please enter a name for the cumulative file: ', 's');
                    cumu_fileName = strcat(cumu_fileName,'.xlsx');
                    for i = 1:4
                        subplot(2,2,i);
                        h = get(gca, 'Children');
                        x = get(h, 'XData');
                        y = get(h, 'YData');
                        cumu_data{i, 1} = x;
                        cumu_data{i, 2} = y;
                        cumu_titles{i} = get(get(gca, 'Title'), 'String');
                    end
                    T = table();
                    for i = 1:4
                        x_data = cumu_data{i, 1}';
                        y_data = cumu_data{i, 2}';
    
                        x_data = x_data(2:end-1);
                        y_data = y_data(2:end-1);
    
                        T.([titles{i}]) = x_data;
                        T.([titles{i} '_prob']) = y_data;
                    end
                    fullFilePath = fullfile(cumu_exportPath, cumu_fileName);
                    writetable(T, fullFilePath)
                end
            case 'angle'
                figure
                titles = ["Rmax 0deg", "c50 0deg", "n 0deg","s 0deg","Rmax 90deg",...
                    "c50 90deg", "n 90deg","s 90deg","Rmax 120deg", "c50 120deg", "n 120deg",...
                    "s 120deg","Rmax 210deg", "c50 210deg", "n 210deg","s 210deg"];
                
                for i = 1:16
                    subplot(4,4,i)
                    data = temp_plot.(table_col_names(i));
                    cdfplot(data);
                    xlabel(titles(i));
                    title(titles(i));
                end
                if export
                    cumu_data = cell(16, 2); 
                    cumu_titles = cell(16, 1);
                    cumu_exportPath = '/mnt/NAS_UserStorage/georgioskeliris/MECP2TUN/exported_cumulative/';
                    cumu_fileName = input('Please enter a name for the cumulative file: ', 's');
                    cumu_fileName = strcat(cumu_fileName,'.xlsx');
                    for i = 1:16
                        subplot(4,4,i);
                        h = get(gca, 'Children');
                        x = get(h, 'XData');
                        y = get(h, 'YData');
                        cumu_data{i, 1} = x;
                        cumu_data{i, 2} = y;
                        cumu_titles{i} = get(get(gca, 'Title'), 'String');
                    end
                    lengths = cellfun(@length, cumu_data);

                    % Find the maximum length
                    maxLength = max(max(lengths))-2;
                    T = table();
                    for i = 1:16
                        x_data = cumu_data{i, 1}';
                        y_data = cumu_data{i, 2}';
    
                        x_data = x_data(2:end-1);
                        y_data = y_data(2:end-1);
    
                        if length(x_data) < maxLength
                            x_data((end+1):maxLength) = NaN;
                        end
                        if length(y_data) < maxLength
                            y_data((end+1):maxLength) = NaN;
                        end
                        T.([titles{i}]) = x_data;
                        T.([titles{i} '_prob']) = y_data;
                    end
                    fullFilePath = fullfile(cumu_exportPath, cumu_fileName);
                    writetable(T, fullFilePath)
                end
        end  
end         




