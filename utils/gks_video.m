
caxis([-14 1000])

v = VideoWriter('~/M483_contrast.avi')
v.FrameRate=5;
open(v)

for i=50:150
    image(mean(tif(:,:,i),3)*1014/8192);
    axis equal; axis off;
    xlim([0 340]); ylim([2700 3200]);
    %pause(0.25);
    
    frame = getframe(gcf);
    writeVideo(v,frame);
end
close(v)


ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh1');
sds=gk_selectDS(ds)
tif = tiffreadVolume(fullfile(sds.rawPath,sds.firstTiff));

colormap gray
imagesc(0.4017*[0:511],1.0034*[0:1113],mean(tif(:,:,1:8:100*8),3));
axis equal; axis off
ylim([600 1000])


v = VideoWriter('~/M11_contrast.avi')
v.FrameRate=5;
open(v)

for i=1:8:100*8+1
    imagesc(0.4017*[0:511],1.0034*[0:1113],tif(:,:,i));
    axis equal; axis off;
    ylim([600 1000])
    
    frame = getframe(gcf);
    writeVideo(v,frame);
end
close(v)

%M12 0.5159 0.862
ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh1');
sds=gk_selectDS(ds)
tif = tiffreadVolume(fullfile(sds.rawPath,sds.firstTiff));

imagesc(0.5159*[0:511],0.862*[0:1187],mean(tif(:,:,1:8:20*8),3));
caxis auto; axis image; ylim([50 400])
colorbar

%M18 0.4503    0.8620
ds = gk_datasetQuery('week','w11','expID','contrast','cohort','coh1');
sds=gk_selectDS(ds)
tif = tiffreadVolume(fullfile(sds.rawPath,sds.firstTiff));
imagesc(0.4503*[0:511],0.862*[0:1203],mean(tif(:,:,1:8:1*8),3));
caxis auto; axis image; 
colorbar
ylim([400 550])
xlim([0 100])
%% Stavroula

ds = gk_datasetQuery('week','w22','expID','contrast','cohort','coh3');
sds=gk_selectDS(ds);
tif = tiffreadVolume(fullfile(sds.rawPath,sds.firstTiff));

colormap gray
imagesc(1*[0:605],1*[0:4997],mean(tif(:,:,1),3));
axis equal; axis off
%ylim([0 1600]);
%ylim([1400 1600]); xlim([400 600])
ylim([1290 3129])
caxis([0 200])

