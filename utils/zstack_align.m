cd /mnt/NAS_UserStorage/Mingyu/learning/2P imaging/cohort Thy1_tg1/M834_Thy1/20250404/zstack41um
folder =  pwd;
files = dir('*.tif');
data = loadMultiTiff(pwd,'*.tif');
ops = gk_SI_tiffInfo(fullfile(files(1).folder,files(1).name));
data = single(reshape(data,size(data,1),size(data,2), ops.numSlices, ops.numVolumes));

% Get the max dimensions to be able to montage the stitched image
Sx=max(ops.dx+ops.allLx);
Sy=max(ops.dy+ops.allLy);
% Stitch the nROIs in a single 4D volume timeseries
im=single(NaN*zeros(Sy,Sx,ops.numSlices,ops.numVolumes));
for p=1:numel(ops.allLy)
    im(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:,:)=...
        data(ops.lines_from(p):ops.lines_to(p),:,:,:);
end

% Check if nROIs have overlap and blend them linearly
ovl = getRoiOverlap(fullfile(files(1).folder,files(1).name));
if ~isempty(find(cellfun(@isempty,ovl.stitched),1))
    for p=1:numel(ops.allLy)
        if p>1 && ~isempty(ovl.stitched{p-1,p})
            
            overlapFrom=min(ovl.perPlane{p-1,p});
            overlapTo=max(ovl.perPlane{p-1,p});
            
            wgt=repmat(linspace(0,1,overlapTo(1)-overlapFrom(1)+1),overlapTo(2)-overlapFrom(2)+1,1);
            if ops.dx(p-1)<ops.dx(p) % p-1 is to the left
                wgt=fliplr(wgt);
            end
            wgt=repmat(wgt,1,1,ops.numSlices,ops.numVolumes);
            
            overlap1=wgt.*data(ops.lines_from(p-1):ops.lines_to(p-1),...
                overlapFrom(1):overlapTo(1),:,:);
            
            overlapFrom=min(ovl.perPlane{p,p-1});
            overlapTo=max(ovl.perPlane{p,p-1});
            
            overlap2=fliplr(wgt).*data(ops.lines_from(p):ops.lines_to(p),...
                overlapFrom(1):overlapTo(1),:,:);
      
            overlapFrom=min(ovl.stitched{p-1,p});
            overlapTo=max(ovl.stitched{p-1,p});
            
            im(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1),:,:)=...
                overlap1 + overlap2;
            
        end
    end
end
clear data overlap1 overlap2 wgt
%% MOTION CORRECTION
options_rigid = NoRMCorreSetParms('d1',size(im,1),'d2',size(im,2),'d3',size(im,3),...
    'max_shift',15,'us_fac',50);

%% perform motion correction
gcp;
tic; [M1,shifts1,template1,options_rigid] = normcorre(im,options_rigid); toc


%% now try non-rigid motion correction (also in parallel)
options_nonrigid = NoRMCorreSetParms('d1',size(im,1),'d2',size(im,2),'d3',size(im,3),'grid_size',[500,500,10],'bin_width',10,'max_shift',5,'max_dev',3,'us_fac',10,'init_batch',10);

gcp;
tic; [M2,shifts2,template2,options_nonrigid] = normcorre_batch(im,options_nonrigid); toc

%% compute metrics

nnY = quantile(im(:),0.005);
mmY = quantile(im(:),0.995);

[cY,mY,vY] = motion_metrics(im,10);
%[cM1,mM1,vM1] = motion_metrics(M1,10);
[cM2,mM2,vM2] = motion_metrics(M2,10);
T = length(cY);
%% plot metrics
figure;
    ax1 = subplot(2,3,1); imagesc(mY,[nnY,mmY]);  axis equal; axis tight; axis off; title('mean raw data','fontsize',14,'fontweight','bold')
    ax2 = subplot(2,3,2); imagesc(mM2,[nnY,mmY]);  axis equal; axis tight; axis off; title('mean rigid corrected','fontsize',14,'fontweight','bold')
    ax3 = subplot(2,3,3); imagesc(mM2,[nnY,mmY]); axis equal; axis tight; axis off; title('mean non-rigid corrected','fontsize',14,'fontweight','bold')
    subplot(2,3,4); plot(1:T,cY,1:T,cM2,1:T,cM2); legend('raw data','rigid','non-rigid'); title('correlation coefficients','fontsize',14,'fontweight','bold')
    subplot(2,3,5); scatter(cY,cM2); hold on; plot([0.9*min(cY),1.05*max(cM2)],[0.9*min(cY),1.05*max(cM2)],'--r'); axis square;
        xlabel('raw data','fontsize',14,'fontweight','bold'); ylabel('rigid corrected','fontsize',14,'fontweight','bold');
    subplot(2,3,6); scatter(cM2,cM2); hold on; plot([0.9*min(cY),1.05*max(cM2)],[0.9*min(cY),1.05*max(cM2)],'--r'); axis square;
        xlabel('rigid corrected','fontsize',14,'fontweight','bold'); ylabel('non-rigid corrected','fontsize',14,'fontweight','bold');
    linkaxes([ax1,ax2,ax3],'xy')
%% plot shifts        

shifts_r = squeeze(cat(3,shifts1(:).shifts));
shifts_nr = cat(ndims(shifts2(1).shifts)+1,shifts2(:).shifts);
shifts_nr = reshape(shifts_nr,[],ndims(im)-1,T);
shifts_x = squeeze(shifts_nr(:,1,:))';
shifts_y = squeeze(shifts_nr(:,2,:))';

patch_id = 1:size(shifts_x,2);
str = strtrim(cellstr(int2str(patch_id.')));
str = cellfun(@(x) ['patch # ',x],str,'un',0);

figure;
    ax1 = subplot(311); plot(1:T,cY,1:T,cM1,1:T,cM2); legend('raw data','rigid','non-rigid'); title('correlation coefficients','fontsize',14,'fontweight','bold')
            set(gca,'Xtick',[])
    ax2 = subplot(312); plot(shifts_x); hold on; plot(shifts_r(:,1),'--k','linewidth',2); title('displacements along x','fontsize',14,'fontweight','bold')
            set(gca,'Xtick',[])
    ax3 = subplot(313); plot(shifts_y); hold on; plot(shifts_r(:,2),'--k','linewidth',2); title('displacements along y','fontsize',14,'fontweight','bold')
            xlabel('timestep','fontsize',14,'fontweight','bold')
    linkaxes([ax1,ax2,ax3],'x')

%% plot a movie with the results

figure;
for t = 1:1:T
    subplot(121);imagesc(im(:,:,t),[nnY,mmY]); xlabel('raw data','fontsize',14,'fontweight','bold'); axis equal; axis tight;
    title(sprintf('Frame %i out of %i',t,T),'fontweight','bold','fontsize',14); colormap('bone')
    subplot(122);imagesc(M2(:,:,t),[nnY,mmY]); xlabel('non-rigid corrected','fontsize',14,'fontweight','bold'); axis equal; axis tight;
    title(sprintf('Frame %i out of %i',t,T),'fontweight','bold','fontsize',14); colormap('bone')
    set(gca,'XTick',[],'YTick',[]);
    drawnow;
    pause(0.02);
end
