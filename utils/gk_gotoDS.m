function pth = gk_gotoDS(ds)
% USAGE: [path] = gk_gotoDS(ds)
%
% A small utility function that returns the path or goes to a dataset
%
% Author: Georgios A. Keliris
if nargin<1
    cd /mnt/NAS_UserStorage/code/GKHub/gk2Putils
    return
end


ds = gk_selectDS(ds);

if nargout>0
    pth = fullfile(setSesPath(ds),'matlabana');
else
    cd(fullfile(setSesPath(ds),'matlabana'));
end