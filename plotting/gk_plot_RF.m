function gk_plot_RF(sig, roiNum, stim)
% USAGE: gk_plot_RF(sig, roiNum, stim)
%
% Function that plots the RF of roi/neuron
%
% Input: sig - a structure returned by gk_getSigTrials
%        roiNum - the number of the roi/neuron in sig
%        stim - the stim structure
%
% Author: Georgios A. Keliris
% v1.0 - 17 Oct 2022 

[~,~,x]=unique(stim.uniquePos(:,1));
[~,~,y]=unique(stim.uniquePos(:,2));
for pos = 1: size(stim.uniquePos,1)
    tmp = squeeze(sig.trials_ONresp(roiNum,:,find(stim.posIDs==pos)));
    resp(pos).trials = tmp(:);
    resp(pos).mean = mean(resp(pos).trials);
    resp(pos).sem = std(resp(pos).trials)./sqrt(numel(resp(pos).trials));
    meanImg(x(pos),y(pos))=resp(pos).mean;
    semImg(x(pos),y(pos))=resp(pos).sem;
end

imagesc(meanImg); axis off; axis square
%title(['Num = ' num2str(roiNum)]);
%subplot(1,2,2); surf(unique(x), unique(y), meanImg);


return