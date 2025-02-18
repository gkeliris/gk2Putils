ds = gk_datasetQuery('day','d6','expID','barLR','mouseID','M827')
FTS_LR=gk_getRetPhaseAmp(ds,40);
ds = gk_datasetQuery('day','d6','expID','barRL','mouseID','M827')
FTS_RL=gk_getRetPhaseAmp(ds,40); 
ds = gk_datasetQuery('day','d6','expID','barBU','mouseID','M827')
FTS_BU=gk_getRetPhaseAmp(ds,40); 
ds = gk_datasetQuery('day','d6','expID','barUB1','mouseID','M827')
FTS_UB1=gk_getRetPhaseAmp(ds,40); 
ds = gk_datasetQuery('day','d6','expID','barUB2','mouseID','M827')
FTS_UB2=gk_getRetPhaseAmp(ds,40); 

raw_azimuthMap=(FTS_LR.stxPHS-FTS_RL.stxPHS)/2;
raw_altitudeMap=(FTS_BU.stxPHS-FTS_UB2.stxPHS)/2;

azimuthMap = imgaussfilt(raw_azimuthMap, 5);
altitudeMap = imgaussfilt(raw_altitudeMap, 5);

% Compute spatial gradients using finite difference method
[dx_az, dy_az] = gradient(azimuthMap);
[dx_alt, dy_alt] = gradient(altitudeMap);

% Compute Jacobian determinant
jacobianDet = (dx_az .* dy_alt) - (dy_az .* dx_alt);

% Compute the field sign (sign of Jacobian determinant)
fieldSignMap = sign(jacobianDet);

% Display the field-sign map
figure;
imagesc(fieldSignMap);
colormap('jet'); % Use blue/red colormap to visualize +1 and -1
colorbar;
axis image;
title('Field-Sign Map');

hold on;
contour(azimuthMap, 10, 'k'); % Contours of azimuth map
contour(altitudeMap, 10, 'w'); % Contours of altitude map
hold off;