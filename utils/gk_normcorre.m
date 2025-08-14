function data = gk_normcorre(data, non_rigid, opts)
% USAGE: data = gk_normcorre(data, [non_rigid], [opts])
%
% INPUTS: data <- the struct returned by gk_directLoadTiffs
%
%         non_rigid (boolean - default:false): whether to perform non_rigid
%
%         opts: a structure with fields to potentially change from default
%
% uses: NoRMCorre package to do the motion correction

% Author: GAK July 2025


if nargin<2
    non_rigid=false;
end
if exist("opts","var")
    adjust_options = true;
    fn=fieldnames(opts);
else
    adjust_options = false;
end

for pl = 1:numel(data.planes)
    plane = single(data.planes{pl});
    options= NoRMCorreSetParms('d1',size(plane,1),'d2',size(plane,2),...
        'grid_size',[200,200], ...
        'mot_uf',4, ...
        'bin_width', 600, ...
        'max_shift',15, ...
        'max_dev',3, ...
        'us_fac',50, ...
        'init_batch',600);
    if adjust_options
        for f=1:numel(fn)
            options.(fn{f})=opts.(fn{f});
        end
    end
    gcp;
    tic;
    if non_rigid
        [reg_plane,data.shifts{pl},data.template{pl},data.reg_options{pl}] = ...
            normcorre_batch(plane,options);
        data.reg_planes{pl}=int16(reg_plane);
    else
        [reg_plane,data.shifts{pl},data.template{pl},data.reg_options{pl}] = ...
            normcorre(plane,options);
        data.reg_planes{pl}=int16(reg_plane);
    end
    toc;
    clear reg_plane plane
end