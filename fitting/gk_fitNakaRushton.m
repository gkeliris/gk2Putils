function fit = gk_fitNakaRushton(ds,sigName,bef,aft,pval,plt,ROI)
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
    
    if CRF.lowCon(i)      
        [fit.single.params{i}, fit.single.f(i), fit.single.R2(i)] = FitNakaRushton(contrast,response);
        [fit.double.params{i}, fit.double.f(i), fit.double.R2(i)] = FitDoubleNakaRushton(contrast,response,[2 0.05 2.4 2 0.2 2.4]);
        if fit.single.f(i)<=1.5*fit.double.f(i)
            fit.select(i)=1;
        else
            fit.select(i)=2;
        end
    else
        [fit.single.params{i}, fit.single.f(i), fit.single.R2(i)] = FitNakaRushton(contrast,response);
        fit.select(i)=1;
    end

    if plt
        if fit.select(i)==1
            predict = ComputeNakaRushton(fit.single.params{i},fineContrast);
            str=sprintf('A=%.1f, C50=%.2f, n=%.1f',fit.single.params{i});
        else
            predict = ComputeDoubleNakaRushton(fit.double.params{i},fineContrast);
            str=sprintf('A_1=%.1f, C50_1=%.2f, n_1=%.1f, A_2=%.1f, C50_2=%.2f, n_2=%.1f',fit.double.params{i});
        end
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
