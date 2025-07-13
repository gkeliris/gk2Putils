function gk_fillNeuron(imageHeight, imageWidth, stat, cellNum, color, opacity)
% USAGE: gk_fillNeuron(imageHeight, imageWidth, stat, cellNum, color, opacity)
%
% NOTE: before this plot the background image with hold on
%       e.g. figure; imagesc(opsPP.meanImg); axis image; colormap gray; hold on;
%

for c=1:length(cellNum)
    cNum=cellNum(c);
    mask = false(imageHeight, imageWidth);
    mask(sub2ind(size(mask), stat{cNum}.ypix, stat{cNum}.xpix)) = true;

    % Trace the outer boundary of the shape
    boundaries = bwboundaries(mask);
    boundary = boundaries{1};  % Usually the largest boundary

    % Now plot the polygon
    h = fill(boundary(:,2), boundary(:,1),'r');
    set(h, 'FaceColor', color)
    set(h, 'FaceAlpha', opacity);
end