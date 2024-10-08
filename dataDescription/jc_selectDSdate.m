function corrected_paras_file_name = jc_selectDSdate(filepath,ds,sigName)



fileList = dir(filepath);

matchingFiles = {};

 filename_incomplete = ['DS_',ds.cohort{1},'_',ds.week{1},'_', ds.mouseID{1},'_',...
        ds.expID{1},'_',ds.session{1},'_',sigName];
for i = 1:length(fileList)
    % Get the current filename
    currentFile = fileList(i).name;
   
    % Check if the filename matches the pattern up to the date
    if contains(currentFile, filename_incomplete)
        % Extract the date part from the filename
        datePart = extractBetween(currentFile, 'CRF', '.');
        if datePart == ""
            datePart = 'No Date';
        end
        matchingFiles{end+1} =  string(datePart); 
    end
end

if length(matchingFiles) == 1
    corrected_paras_file_name = [filename_incomplete,'_CRF.xlsx'];
else
    fprintf("Multiple dates exist for:\n")
    disp(ds)
    fprintf("Ppick one of the following:\n")
    for j = 1:length(matchingFiles)
        fprintf("Date ID # %i: %s\n",j,string(matchingFiles{j}))
    end
    cellnum = input("Please input the Date ID#: ");
    if strcmp(char(matchingFiles{cellnum}),'No Date')
        corrected_paras_file_name = [filename_incomplete,'_CRF.xlsx'];
    else
        corrected_paras_file_name = ['DS_',ds.cohort{1},'_',ds.week{1},'_', ds.mouseID{1},'_',...
        ds.expID{1},'_',ds.session{1},'_',sigName,'_CRF',char(matchingFiles{cellnum}),'.xlsx'];
    end
end
    
