%% average the datasets before FFT
FTS_azi = gk_retPhaseAmp(ds,0,1);
% select the two LR and RL datasets
FTS_ele = gk_retPhaseAmp(ds,0,1);
% select the two BU and UB datasets
raw_azimuthMap=FTS_azi.phs;
raw_altitudeMap=FTS_ele.phs;

%% average the maps after FFT
FTS_LR = gk_retPhaseAmp(ds(1,:), false, true);
FTS_RL = gk_retPhaseAmp(ds(2,:), false, true);
FTS_BU = gk_retPhaseAmp(ds(3,:), false, true);
FTS_UB = gk_retPhaseAmp(ds(4,:), false, true);
raw_azimuthMap=(FTS_LR.phs + FTS_RL.phs) ./2;
raw_altitudeMap=(FTS_BU.phs + FTS_UB.phs) ./2;


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