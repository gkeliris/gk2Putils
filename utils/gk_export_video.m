function gk_export_video(data3D,outfilepath,origFrameRate,averageframes)
tic 
data3D=double(data3D);

% Use a sample of the first 100 frames to calculate percentiles
vals=reshape(data3D(:,:,1:100),[],1);
lowhigh = quantile(vals, [0.01 0.99]);

% Normalize 3D matrix
data3D = (data3D - lowhigh(1)) ./ diff(lowhigh);
data3D(data3D < 0) = 0; data3D(data3D > 1) = 1;

v = VideoWriter(outfilepath);
v.FrameRate = origFrameRate/averageframes;
open(v);

cmap = gray;

nFrames=size(data3D,3);
for i=1:averageframes:nFrames
    imagesc(mean(data3D(:,:,i:i+averageframes-1),3));
    colormap(cmap);
    axis image off; 
    clim([0 1]);
    frame = getframe(gcf);
    writeVideo(v,frame);
end
close(v)
toc


