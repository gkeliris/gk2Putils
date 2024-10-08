function ds = jc_selectmanyDS(ds)
% USAGE: ds = jc_selectmanyDS(ds)
%
% INPUT:
%   ds :   the output of gk_datasetQuery
%  
% OUTPUT
%   ds:    the mice wanted for the analysis


if size(ds,1)>1
    fprintf('There are more than one datasets entered!\n');
    fprintf('The list is the following:\n')
    disp(ds);
    datID = str2num(input('Please select datIDs, seperated by comma ("4, 6, 9"): ','s'));
    filtered_ds = table;
    for id = datID
        filtered_ds = [filtered_ds; ds(ds.datID == id, :)];
    end
    ds = filtered_ds;
end
