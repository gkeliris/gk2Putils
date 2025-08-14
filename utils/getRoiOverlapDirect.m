function [ovl, ops] = getRoiOverlapDirect(ds, addOvl)
% USAGE: [ovl, ops] = getRoiOverlapDirect(ds, [addOvl])
%
% INPUT
% ds : can be the dataset table or the name of the tiff file
% addOvl : a two element vector [addDX, addDY] values to add to the overlap
%
% Function that returns a structure (ovl) that contains the pixels
% overlapping between pairs of ROIs.

% Author: Georgios A. Keliris
% v0.1 Apr 03, 2025

if nargin<2
    addOvl=[0, 0];
end

% if istable(ds)
%     ds = gk_selectDS(ds);
%     try
%         ops=loadOps(ds);
%     catch
%         ops=gk_SI_tiffInfo(ds);
%     end
% else
    ops=ds.info;
% end
nROIs=numel(ops.dx);
% adjust ops.dx, ops.dy to add additional overlap
for p=2:nROIs
   ops.dx(p)=ops.dx(p)-(p-1)*addOvl(1);
   ops.dy(p)=ops.dy(p)-(p-1)*addOvl(2);
end

% Get the max dimensions to be able to montage the stitched image
Sx=max(ops.dx+ops.allLx);
Sy=max(ops.dy+ops.allLy);

% Check if there is overlap over planes
for p=1:nROIs
        [pixelind{p}.X pixelind{p}.Y]=meshgrid(...
            ops.dx(p)+1:ops.dx(p)+ops.allLx(p),ops.dy(p)+1:ops.dy(p)+ops.allLy(p));
end
ovl.stitched=cell(nROIs);
ovl.perPlane=cell(nROIs);
for p=1:nROIs-1
    for p2=1:nROIs
        if p2>p
            tmp=intersect([pixelind{p}.X(:) pixelind{p}.Y(:)], ...
                [pixelind{p2}.X(:) pixelind{p2}.Y(:)],'rows');
            if ~isempty(tmp)
                ovl.stitched{p,p2}=tmp;
                ovl.perPlane{p,p2}=[tmp(:,1)-ops.dx(p) tmp(:,2)-ops.dy(p)];
                ovl.perPlane{p2,p}=[tmp(:,1)-ops.dx(p2) tmp(:,2)-ops.dy(p2)];
            end
        end
    end
end
