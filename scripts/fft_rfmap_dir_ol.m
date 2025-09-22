function result = fft_rfmap_dir(ds, swps, monitorWidth, monitorHeight, thisDir)
% FFT-based receptive field mapping with weighted complex averaging
% for a single sweep direction.
%
% INPUTS:
%   ds.planes{p}             - [X Y T] imaging data for plane p
%   swps.allRelativeIndices  - vector of frame indices (all sweeps concatenated)
%   swps.nSweeps             - number of sweeps
%   monitorWidth/Height      - in degrees
%   thisDir                  - 'LR','RL','UD','DU'
%
% OUTPUT:
%   result.planes{p}.Z       - weighted complex average [X Y]
%   result.planes{p}.phi     - raw FFT phase map [X Y]
%   result.planes{p}.progress- normalized sweep progress [X Y]
%   result.planes{p}.pos     - RF position map [X Y 2]
%   result.planes{p}.amp     - amplitude map [X Y]

%% Parameters
freqIdx = 2; % fundamental frequency bin

%% Reshape indices into [framesPerSweep × nSweeps]
nFramesTotal = numel(swps.allRelativeIndices);
nSweeps      = swps.nSweeps;
nFramesSweep = nFramesTotal / nSweeps;
frameIdxMat  = reshape(swps.allRelativeIndices, nFramesSweep, nSweeps);

%% Loop over planes
for p = 1:numel(ds.planes)
    dat = ds.planes{p};   % [X Y T]
    [nx, ny, ~] = size(dat);

    % Build sweep block: [X Y Sweep time]
    sweeps = nan(nx, ny, nSweeps, nFramesSweep);
    for s = 1:nSweeps
        frames = frameIdxMat(:,s);
        sweeps(:,:,s,:) = dat(:,:,frames);
    end

    % FFT along time
    F = fft(sweeps, [], 4);   % [X Y Sweep freq]
    Ffund = F(:,:,:,freqIdx); % [X Y Sweep]

    % Weighted complex average across sweeps
    mags = abs(Ffund);
    Zavg = sum(Ffund .* mags, 3) ./ sum(mags, 3);

    % Extract phase and normalize to progress [0..1]
    phi  = angle(Zavg);
    progress = mod(phi, 2*pi) / (2*pi);

    % Map to monitor coordinates depending on direction
    switch thisDir
        case 'LR'
            posX = progress * monitorWidth;
            posY = nan(nx,ny);
        case 'RL'
            posX = (1-progress) * monitorWidth;
            posY = nan(nx,ny);
        case 'UD'
            posX = nan(nx,ny);
            posY = progress * monitorHeight;
        case 'DU'
            posX = nan(nx,ny);
            posY = (1-progress) * monitorHeight;
        otherwise
            error('Unknown direction: %s', thisDir);
    end

    % Store results
    result.planes{p}.Z        = Zavg;
    result.planes{p}.phi      = phi;
    result.planes{p}.progress = progress;
    result.planes{p}.pos      = cat(3, posX, posY);
    result.planes{p}.amp      = abs(Zavg);
end
end
