%%
p=pathtofirsttif;
LR=gk_directLoadTiffs(p);
LR.expID='barLR';
stimLR = gk_getRetinotopyStim;
FTS_LR = gk_direct_retPhaseAmp(RL, false, true, stimLR, 0, false);
figure; imagesc(rot90(FTS_LR.mean_image,2)');
figure; imagesc(rot90(FTS_LR.phs,2)');
figure; imagesc(rot90(FTS_LR.amp,2)');
caxis([0 90]);
%%
RL=gk_directLoadTiffs;
RL.expID='barRL';
stimRL = gk_getRetinotopyStim;
FTS_RL = gk_direct_retPhaseAmp(RL, false, true, stimRL, 1, false);
figure; imagesc(rot90(FTS_RL.mean_image,2)');
figure; imagesc(rot90(FTS_RL.phs,2)');
figure; imagesc(rot90(FTS_RL.amp,2)');
%%
BU=gk_directLoadTiffs;
BU.expID='barBU';
stimBU = gk_getRetinotopyStim;
FTS_BU = gk_direct_retPhaseAmp(BU, false, true, stimBU, 0, false);
figure; imagesc(rot90(FTS_BU.mean_image,2)');
figure; imagesc(rot90(FTS_BU.phs,2)');
figure; imagesc(rot90(FTS_BU.amp,2)');
%%
UB=gk_directLoadTiffs;
UB.expID='barUB';
stimUB = gk_getRetinotopyStim;
FTS_UB = gk_direct_retPhaseAmp(UB, false, true, stimUB, 1, false);
figure; imagesc(rot90(FTS_UB.mean_image,2)');
figure; imagesc(rot90(FTS_UB.phs,2)');
figure; imagesc(rot90(FTS_UB.amp,2)');
%%
raw_azimuthMap=(FTS_LR.phs + FTS_RL.phs) ./2;
raw_altitudeMap=(FTS_BU.phs + FTS_UB.phs) ./2;
%%
raw_azimuthAmp=(FTS_LR.amp + FTS_RL.amp) ./2;
raw_altitudeAmp=(FTS_BU.amp + FTS_UB.amp) ./2;

%% CALCULATE THE field-sign maps
neg_ind=find(raw_azimuthMap<0);
pos_ind=find(raw_azimuthMap>=0);
raw_azimuthMap(neg_ind)=-raw_azimuthMap(neg_ind);
raw_azimuthMap(pos_ind)=2*pi-raw_azimuthMap(pos_ind);
neg_ind=find(raw_altitudeMap<0);
pos_ind=find(raw_altitudeMap>=0);
raw_altitudeMap(neg_ind)=-raw_altitudeMap(neg_ind);
raw_altitudeMap(pos_ind)=2*pi-raw_altitudeMap(pos_ind);

%replace NaNs with random noise [0,2pi] so that they are not propageted by
%filtering
aznoise=2*pi*rand(size(raw_azimuthMap));
raw_azimuthMap(isnan(raw_azimuthMap))=aznoise(isnan(raw_azimuthMap));
alnoise=2*pi*rand(size(raw_altitudeMap));
raw_altitudeMap(isnan(raw_altitudeMap))=alnoise(isnan(raw_altitudeMap));

azimuthMap = imgaussfilt(raw_azimuthMap, 40);
altitudeMap = imgaussfilt(raw_altitudeMap, 40);
figure; imagesc(rot90(azimuthMap,2)');

% Compute spatial gradients using finite difference method
[dx_az, dy_az] = gradient(azimuthMap);
[dx_alt, dy_alt] = gradient(altitudeMap);

% Compute Jacobian determinant
jacobianDet = (dx_az .* dy_alt) - (dy_az .* dx_alt);

% Compute the field sign (sign of Jacobian determinant)
fieldSignMap = sign(jacobianDet);

% Display the field-sign map
figure;
%imagesc(fieldSignMap);
imagesc(rot90(fieldSignMap,2)');
colormap('jet'); % Use blue/red colormap to visualize +1 and -1
%colorbar;
axis image;
title('Field-Sign Map');

hold on;
contour(rot90(azimuthMap,2)', 10, 'w'); % Contours of azimuth map
contour(rot90(altitudeMap,2)', 10, 'r'); % Contours of altitude map
hold off;