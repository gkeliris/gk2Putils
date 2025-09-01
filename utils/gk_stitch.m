function ds = gk_stitch(ds)
% USAGE: ds = gk_stitch(ds)
%
% Inputs: ds :the output of gk_directLoadTiffs
%
% See also: stitchMultiTiff

ops=ds.info;
%planes=planes{1};
% Get the max dimensions to be able to montage the stitched image
Sx=max(ops.dx+ops.allLx);
Sy=max(ops.dy+ops.allLy);
% Define mean_image, PHS, AMP stitched matrices
ds.stitched=NaN*zeros(Sy,Sx,size(ds.planes{1},3));

for p=1:numel(ds.planes)
    ds.stitched(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),...
        ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:)=ds.planes{p};
end