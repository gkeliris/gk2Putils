function [FTS, mean_image] = gk_getRetPhaseAmp(ds,FREQ)

ds2=jc_selectmanyDS(ds);
tic
for d=1:2
    ds=ds2(d,:);
    % Get the full stitched (stx) matrix
    ops=loadOps(ds);
    Sx=max(ops.dx+ops.allLx);
    Sy=max(ops.dy+ops.allLy);
    FTS.stxPHS=NaN*zeros(Sy,Sx);
    FTS.stxAMP=NaN*zeros(Sy,Sx);
    
    % load the timings to find onset and offset of stimulus
    load(fullfile(setSesPath(ds),'matlabana','stim.mat'));
    % See the intervals
    Delta=stim.Times.frame_onsets(2:end)-stim.Times.frame_offsets(1:end-1);
    [counts, centers]=hist(Delta,1:max(Delta));
    [~,ipks]=findpeaks(counts);
    addFrames=centers(ipks(end));
    
    endSweeps_ind=find(Delta>=ipks(end));
    endSweeps=[stim.Times.frame_offsets(endSweeps_ind) stim.Times.frame_offsets(end)];
    nSweeps=numel(endSweeps);
    
    startSweeps(1)=stim.Times.frame_onsets(1);
    for n=2:nSweeps
        startSweeps(n)=stim.Times.frame_onsets(endSweeps_ind(n-1)+1);
    end
    sweepLength=endSweeps'-startSweeps';
    useSweepLength = min(sweepLength);
    
    % Get the period where the stimulus was shown
    if ~isempty(strfind(ds.expID,'barLR')) || ~isempty(strfind(ds.expID,'barBU'))
        reverse=false;
        start=stim.Times.frame_onsets(1);
        stop=stim.Times.frame_offsets(end)+addFrames;
    elseif  ~isempty(strfind(ds.expID,'barRL')) || ~isempty(strfind(ds.expID,'barUB'))
        reverse=true;
        start=stim.Times.frame_onsets(1)-addFrames;
        stop=stim.Times.frame_offsets(end);
    end
    startSweeps=startSweeps-start+1;
    all_indices=[];
    for n=1:nSweeps
        all_indices=[all_indices startSweeps(n):startSweeps(n)+useSweepLength];
    end
 
    br{d}=NaN*zeros(Sy,Sx,stop-start+1);
    
    % Find the folders for each plane_ROI
    planes=dir(fullfile(setSesPath(ds),'suite2p_orig','plane*'));
    
    % load the data from the tiff images
    for p=1:numel(planes)
        
        %     d=dir(fullfile(setSesPath(ds),'suite2p_orig',planes(p).name,'reg_tif','*.tif'));
        
        %     % Read the tiff files
        %     im=[];
        %     for i=1:numel(d)
        %         im=cat(3,im,parallelReadTiff(fullfile(d(i).folder,d(i).name)));
        %         fprintf('%s, tiff%d\n',planes(p).name,i);
        %     end
        
        %im{p} = loadSuite2pBinary(ds, p-1);
        br{d}(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:) =...
            loadSuite2pBinary(ds, p-1, start, stop);
        
        
    end
    % cut it in sweeps of equal length
    br{d}=br{d}(:,:,all_indices);
    
end
mean_image=mean(br{1},3);
% Define some parameters for the FFT
L=numel(all_indices);
Fs=L; % frames/scan
Fn = Fs/2;
Fv = linspace(0,1,fix(L/2)+1)*Fn;
Iv = 1:length(Fv);

im=NaN*zeros(Sy,Sx,L);
try
    im=(br{1}+br{2}(:,:,end:-1:1))/2;
catch
    keyboard
end


[Dim1,Dim2,~]=size(im);
%im=double(reshape(im(:,:,start:stop),Dim1*Dim2,L));
im=double(reshape(im,Dim1*Dim2,L));

fprintf('Calculating FFT..\n');
fts=fft(im')/L;
F.amp = abs(fts(Iv,:))*2;
F.phs = angle(fts(Iv,:));
%ampRatio1=amp_FTS(find(Fv==40),:)./mean(amp_FTS(find((Fv>1 & Fv<39) | (Fv>41 & Fv<100)),:));
FTS.stxAMP=reshape(F.amp(Fv>FREQ-0.4 & Fv<FREQ+0.4,:),Dim1,Dim2);
FTS.stxPHS=reshape(F.phs(Fv>FREQ-0.4 & Fv<FREQ+0.4,:),Dim1,Dim2);

%FTS.stxAMP(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:)=FTS.FREQamp{p};
%FTS.stxPHS(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:)=FTS.FREQphs{p};



toc

