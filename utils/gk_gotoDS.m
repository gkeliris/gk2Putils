function path = gk_gotoDS(ds)
% USAGE: [path] = gk_gotoDS(ds)
%
% A small utility function that returns the path or goes to a dataset
%
% Author: Georgios A. Keliris
ds = gk_selectDS(ds);

if nargout>0
    path = setSesPath(ds);
else
    cd(setSesPath(ds));
end