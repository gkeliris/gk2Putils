function pth = gk_getDESpath(pathType,coh,wk,ms,ex)
% USAGE: pth = gk_getDESpath(pathType,coh,wk,ms,ex)
%
% pathType: 'proc' or 'raw'
%
% Author: Georgios A. Keliris

load('/mnt/Toshiba_16TB_1/all_exp_description.mat');


if strcmp(upper(pathType),'PROC')
    pth=DES.(coh).(wk).(ms).(ex).procPath;
elseif strcmp(upper(pathType),'RAW')
    pth=DES.(coh).(wk).(ms).(ex).rawPath;
end
