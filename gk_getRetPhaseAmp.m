function FTS = gk_getRetPhaseAmp(ds,FREQ)

ds=gk_selectDS(ds);
tic
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

% Get the period where the stimulus was shown
start=stim.Times.frame_onsets(1);
stop=stim.Times.frame_offsets(end)+addFrames;

% Define some parameters for the FFT
L=stop-start+1;
Fs=L; % frames/scan
Fn = Fs/2;
Fv = linspace(0,1,fix(L/2)+1)*Fn;
Iv = 1:length(Fv);

% Find the folders for each plane_ROI
planes=dir(fullfile(setSesPath(ds),'suite2p_orig','plane*'));

% load the data from the tiff images
for p=1:numel(planes)
    d=dir(fullfile(setSesPath(ds),'suite2p_orig',planes(p).name,'reg_tif','*.tif'));
    
    % Read the tiff files
    im=[];
    for i=1:numel(d)
        im=cat(3,im,parallelReadTiff(fullfile(d(i).folder,d(i).name)));
        fprintf('%s, tiff%d\n',planes(p).name,i);
    end
    [Dim1,Dim2,~]=size(im);
    im=double(reshape(im(:,:,start:stop),Dim1*Dim2,L));
    fprintf('Calculating FFT..\n');
    fts=fft(im')/L;
    FTS.amp{p} = abs(fts(Iv,:))*2;
    FTS.phs{p} = angle(fts(Iv,:));
    %ampRatio1=amp_FTS(find(Fv==40),:)./mean(amp_FTS(find((Fv>1 & Fv<39) | (Fv>41 & Fv<100)),:));
    FTS.FREQamp{p}=reshape(FTS.amp{p}(Fv>FREQ-0.4 & Fv<FREQ+0.4,:),Dim1,Dim2);
    FTS.FREQphs{p}=reshape(FTS.phs{p}(Fv>FREQ-0.4 & Fv<FREQ+0.4,:),Dim1,Dim2);

    FTS.stxAMP(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:)=FTS.FREQamp{p};
    FTS.stxPHS(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p),:)=FTS.FREQphs{p};

end

toc

