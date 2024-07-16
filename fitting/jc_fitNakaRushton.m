function fit = jc_fitNakaRushton(ds,sigName,bef,aft,pval,plt,ROI)
% USAGE: fit = gk_fitNakaRushton(ds,sigName,bef,aft,pval,[plt],[ROI])
%     or fit = gk_fitNakaRushton(CRF,[plt],[ROI]);
%
% Author: Georgios A. Keliris
%
% See also gk_CRF, gk_get_CRFs

if nargin<3
    if nargin<2
        plt=false;
    end
    CRF=ds;
    plt=sigName;
else
    CRF = gk_CRF(ds,sigName,bef,aft,pval);
end
if nargin > 2 && nargin < 5
    plt=false;
end
if plt
    fineContrast = linspace(0,1,100);
end
if nargin==10
    cells=ROI;
else
    cells=1:numel(CRF.roiNums);
end
fit.CRF = CRF;
contrast=CRF.stimValues'/100;

for i=[cells]
    response=double(CRF.sigMean(i,:));
    
    [fit.params{i}, fit.f(i), fit.R2(i)] = FitSuperNakaRushton(contrast,response);

    if plt
       predict = ComputeSuperNakaRushton(fit.params{i}, fineContrast);
       str=sprintf('A=%.1f, C50=%.2f, n=%.1f',fit.params{i});
       
        clf; hold on
        plot(contrast,response,'ko','MarkerSize',12,'MarkerFaceColor','k');
        plot(fineContrast,predict,'k','LineWidth',2);
        xlabel('Contrast'); ylabel('Response');
        title(str)
        in = input('press enter to continue or 0 (zero) to exit\n');
        if in==0
            return
        end
    end

end
