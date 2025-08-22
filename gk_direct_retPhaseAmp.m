function FTS = gk_direct_retPhaseAmp(ds, deltaF, useAverageSweep, stim, reverse, directLoad)
% USAGE: FTS = gk_direct_retPhaseAmp(ds, [deltaF], [useAverageSweep], [directLoad])
%
% INPUT:
%   ds -> a table returned by gk_datasetQuery (which reads a .csv file)
%           it has these fields:    ds.datID        -> datasetID
%                                   ds.cohort       -> animal cohort
%                                   ds.day          -> exp timepoint
%                                   ds.session      -> exp session
%                                   ds.mouseID      -> the mouse code name
%                                   ds.expID        -> the type of exp
%                                   ds.rawPath      -> the path to the data
%                                   ds.firstTiff    -> the name of the first tiff file
%
%   deltaF (optional): boolean, if true will convert data to dF/F using the
%           median value of the iterSweep intervals (currently all together)
%           When empty or undefined the defaul is true
%
%   useAverageSweep (optional): boolean, if true the sweeps will be
%           averaged before the FFT is calculated
%
%   directLoad (optional): boolean, if true it loads data directly from
%                           tiffs and performs motion correction

% Author: Georgios A. Keliris
% v0.1 March 20, 2025
% v0.2 April 4, 2025

%% Predefine some info used for calculations
if nargin < 6
    directLoad = false;
end
if nargin < 3
    useAverageSweep = false;
end
if nargin < 2 || isempty(deltaF)
    deltaF=true;
end

if size(ds,1)>2
    fprintf('SELECT A MAX OF TWO (2) CORRESPONDING DATASETS i.e. LR & RL or BU & UB\n');
    ds=jc_selectmanyDS(ds);
end
tic
for d = 1:size(ds,1)
    
    % Load the OPS
    % ops{d}=loadOps(ds(d,:));
    
    % Get the indices of the sweeps
    swps{d}=getSweepsDirect(stim,reverse);
    
    % Find the folders for each plane_ROI
    %planes{d}=dir(fullfile(setSesPath(ds(d,:)),'suite2p_orig','plane*'));
end
%% Define some parameters for the FFT
if useAverageSweep
    % For a single average sweep
    L = numel(swps{1}.allIndRelative)/swps{1}.nSweeps;
else
    % For concatenated or continuous sweeps
    L=numel(swps{1}.allIndRelative);
end
Fs=L; % frames/scan
Fn = Fs/2;
Fv = linspace(0,1,fix(L/2)+1)*Fn;
Iv = 1:length(Fv);

%% Load the data and perform FFT per plane
for p=1:numel(ds.planes)
    for d = 1:size(ds,1)
        %tic
        %fprintf('Loading data: ds %s, plane %d\n',ds(d,:).expID, p);
        plane{p,d}=ds.planes{p};%loadSuite2pBinary(ds(d,:), p-1, swps{d}.start, swps{d}.stop);
        %toc
        % calculate the mean image per plane
        mean_image{p,d} = mean(plane{p,d},3);
        plane{p,d}=double(plane{p,d});
        
        if deltaF
            tic
            fprintf('Calculating dF/F: plane %d\n',p);
            % Calculate F0 as the median of the inter sweep intervals
            F0{p,d} = median(plane{p,d}(:,:,swps{d}.interIndRelative),3);
            % Convert data to deltaF/F
            plane{p,d} = (plane{p,d} - repmat(F0{p,d},1,1,size(plane{p,d},3))) ./ ...
                repmat(F0{p,d},1,1,size(plane{p,d},3));
            toc
        end
        plane{p,d}=plane{p,d}(:,:,swps{d}.allIndRelative);
        [Dim1,Dim2,~]=size(plane{p,d});
        if useAverageSweep
            sweeps=reshape(plane{p,d},size(plane{p,d},1),size(plane{p,d},2),...
                swps{d}.useSweepLength+1,swps{d}.nSweeps);
            choice=1:size(sweeps,4);
            plane{p,d}=mean(sweeps(:,:,:,choice),4);
            FREQ_low = 1 - Fv(2)/2;  % Fv(2) is the Freq resolution (Fv(1)=0)
            FREQ_high = 1 + Fv(2)/2;
        else
            FREQ_low = swps{1}.nSweeps - Fv(2)/2;
            FREQ_high = swps{1}.nSweeps + Fv(2)/2;
        end
        tmp{d}=reshape(plane{p,d},Dim1*Dim2,L);
    end
    
    if ~isempty(strfind(ds(1,:).expID,'barLR')) || ~isempty(strfind(ds(1,:).expID,'barBU'))
        if numel(tmp)==2
            br = (tmp{1} + fliplr(tmp{2}))./2;
        else
            br = tmp{1};
        end
    elseif ~isempty(strfind(ds.expID,'barRL')) || ~isempty(strfind(ds.expID,'barUB'))
        if numel(tmp)==2
            br = (fliplr(tmp{1}) + tmp{2})./2;
        else
            br = fliplr(tmp{1});
        end
    elseif ~isempty(strfind(ds.expID,'5dots'))
        br = tmp{1};
    else
        keyboard
    end       
    
    fprintf('Calculating FFT plane %d..\n',p);
    tic
    fts=fft(br')/L;
    toc
    F_amp = abs(fts(Iv,:))*2;
    F_phs = angle(fts(Iv,:));

    FTS.ampPerPlane{p}=reshape(F_amp(Fv>FREQ_low & Fv<FREQ_high,:),Dim1,Dim2);
    FTS.phsPerPlane{p}=reshape(F_phs(Fv>FREQ_low & Fv<FREQ_high,:),Dim1,Dim2);

end

%% Stitch the planes into a single map
if size(ds,1)==2
    for p=1:numel(planes{1})
        mean_image{p,1}= (mean_image{p,1} + mean_image{p,2})./2;
    end
end
ops=ds.info;
%planes=planes{1};
% Get the max dimensions to be able to montage the stitched image
Sx=max(ops.dx+ops.allLx);
Sy=max(ops.dy+ops.allLy);
% Define mean_image, PHS, AMP stitched matrices
FTS.mean_image=NaN*zeros(Sy,Sx);
FTS.phs=NaN*zeros(Sy,Sx);
FTS.amp=NaN*zeros(Sy,Sx);

for p=1:numel(ds.planes)
    FTS.mean_image(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p))=...
        mean_image{p,1};
    FTS.phs(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p))=...
        FTS.phsPerPlane{p};
    FTS.amp(ops.dy(p)+1:ops.dy(p)+ops.allLy(p),ops.dx(p)+1:ops.dx(p)+ops.allLx(p))=...
        FTS.ampPerPlane{p};
end
%% Replace potential overlap between planes with a linear blend
% Check if there is overlap over planes
ovl = getRoiOverlapDirect(ds);
if ~isempty(find(cellfun(@isempty,ovl.stitched),1))
    for p=1:numel(ds.planes)
        if p>1 && ~isempty(ovl.stitched{p-1,p})
            
            overlapFrom=min(ovl.perPlane{p-1,p});
            overlapTo=max(ovl.perPlane{p-1,p});
            
            wgt=repmat(linspace(0,1,overlapTo(1)-overlapFrom(1)+1),overlapTo(2)-overlapFrom(2)+1,1);
            if ops.dx(p-1)<ops.dx(p) % p-1 is to the left
                wgt=fliplr(wgt);
            end
            
            overlap1.mimg=wgt.*mean_image{p-1}(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1));
            overlap1.phs=wgt.*FTS.phsPerPlane{p-1}(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1));
            overlap1.amp=wgt.*FTS.ampPerPlane{p-1}(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1));
            
            overlapFrom=min(ovl.perPlane{p,p-1});
            overlapTo=max(ovl.perPlane{p,p-1});
            
            overlap2.mimg=fliplr(wgt).*mean_image{p}(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1));
            overlap2.phs=fliplr(wgt).*FTS.phsPerPlane{p}(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1));
            overlap2.amp=fliplr(wgt).*FTS.ampPerPlane{p}(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1));
      
            overlapFrom=min(ovl.stitched{p-1,p});
            overlapTo=max(ovl.stitched{p-1,p});
            
            FTS.mean_image(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1))=overlap1.mimg + overlap2.mimg;
            FTS.phs(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1))=overlap1.phs + overlap2.phs;
            FTS.amp(overlapFrom(2):overlapTo(2),overlapFrom(1):overlapTo(1))=overlap1.amp + overlap2.amp;
            
        end
    end
end




