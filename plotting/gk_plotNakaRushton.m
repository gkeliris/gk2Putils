function gk_plotNakaRushton(fit, ROInum)
% USAGE: gk_plotNakaRushton(fit, ROInum)
%
% INPUT:
%   fit: returned by gk_fitNakaRushton
%   ROInum: the roi number to plot
%
% GAK Nov 2023
%
% See also gk_fitNakaRushton
if nargin<2
    ROInum=1;
end

figure;
i=ROInum;
fineContrast = linspace(0,1,100);
contrast=fit.CRF.stimValues'/100;
response=double(fit.CRF.sigMean(i,:));
if fit.select(i)==1
    predict = ComputeNakaRushton(fit.single.params{i},fineContrast);
    str=sprintf('A=%.1f, C50=%.2f, n=%.1f',fit.single.params{i});
    txt= ['R^2=', num2str(fit.single.R2(i))];

else
    predict = ComputeDoubleNakaRushton(fit.double.params{i},fineContrast);
    str=sprintf('A_1=%.1f, C50_1=%.2f, n_1=%.1f, A_2=%.1f, C50_2=%.2f, n_2=%.1f',fit.double.params{i});
    txt=['R^2=', num2str(fit.double.R2(i))];
end
clf; hold on
plot(contrast,response,'ko','MarkerSize',12,'MarkerFaceColor','k');
plot(fineContrast,predict,'k','LineWidth',2);
text(0.8,-0.2,txt)
xlabel('Contrast'); ylabel('Response');
title(str)

