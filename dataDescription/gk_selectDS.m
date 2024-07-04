function ds = gk_selectDS(ds)
% USAGE: ds = gk_selectDS(ds)
%
% A small utility function that prompts the user to select a single dataset
% in cases the ds table contains more than one row
%
% Author: Georgios A. Keliris

if size(ds,1)>1
    fprintf('There are more than one datasets entered!\n');
    fprintf('The list is the following:\n')
    disp(ds);
    datID = input('Please select one datID: ','s');
    ds = ds(ds.datID==str2double(datID),:);
    disp(ds);
end