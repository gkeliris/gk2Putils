function corrected_paras_file_name = jc_selectDSdate(filepath, ds, sigName)

fileList = dir(filepath);
matchingFiles = {};

filename_incomplete = ['DS_', ds.cohort{1}, '_', ds.week{1}, '_', ds.mouseID{1}, '_', ...
    ds.expID{1}, '_', ds.session{1}, '_', sigName];

for i = 1:length(fileList)
    % Get the current filename
    currentFile = fileList(i).name;
   
    % Check if the filename matches the pattern up to the date
    if contains(currentFile, filename_incomplete)
        % Extract the date part from the filename
        datePart = extractBetween(currentFile, 'CRF', '.');
        if isempty(datePart{1})
            % This means thats this is the old format with no date
            datePart = 'No Date';
        else
            %Get rid of underscore at the beginning for aesthetics
            datePart = datePart{1}(2:end);
        end
        matchingFiles{end+1} = string(datePart); 
    end
end

if (length(matchingFiles) == 1) && strcmp(matchingFiles{1},"No Date")
    %If there is only one file that has no date this is the output filename
    corrected_paras_file_name = [filename_incomplete, '_CRF.xlsx'];
elseif length(matchingFiles) == 1
    %If there is only one file with a date this is the output filename
    corrected_paras_file_name = [filename_incomplete, '_CRF_', char(matchingFiles{1}), '.xlsx'];
else
    %Otherwise, if there are multiple dates we have to ask user
    fprintf("Multiple dates exist for:\n")
    disp(ds)
    fprintf("Pick one of the following:\n")
    for j = 1:length(matchingFiles)
        fprintf("Date ID # %i: %s\n", j, string(matchingFiles{j}))
    end
    cellnum = input("Please input the Date ID#: ");
    if strcmp(char(matchingFiles{cellnum}), 'No Date')
        corrected_paras_file_name = [filename_incomplete, '_CRF.xlsx'];
    else
        corrected_paras_file_name = ['DS_', ds.cohort{1}, '_', ds.week{1}, '_', ds.mouseID{1}, '_', ...
            ds.expID{1}, '_', ds.session{1}, '_', sigName, '_CRF_', char(matchingFiles{cellnum}), '.xlsx'];
    end
end
