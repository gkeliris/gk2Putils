function prm = fit_contrast(stim,sig,fitChoice)
% USAGE: prm = fit_contrast(stim,sig,fitChoice)
%
% utility function to fit contrast responses

if nargin<3
    fitChoice='mean';
end

prm.fitChoice = fitChoice;
prm.maxResp = max(0,max(double(sig.Mean)));
prm.medianResp = median(double(sig.Mean));
prm.ft = fittype('Rmax*x.^n/(x.^(n*s)+C50.^(n*s))');
prm.ftopt = fitoptions('Method','NonlinearLeastSquares','Robust','Bisquare','Display','off',...
    'Lower',[0.1, 0, 0.5, 1],'Upper',[100, 10, 20, 3],'StartPoint',[50, 2, 2, 1]);
if strcmp(fitChoice,'wgt')
    prm.ftopt.Weights=[1./sig.Std.^2]';
end
try
    if strcmp(fitChoice,'all')
        [prm.f, prm.gof]=fit(stim.ValuesNtrials(:),double(sig.Trials'), prm.ft, prm.ftopt);
    else
        [prm.f, prm.gof]=fit(stim.Values(:),double(sig.Mean'), prm.ft, prm.ftopt);
    end
catch ME
    prm.gof.adjrsquare=-Inf;
    prm.gof.rsquare=-Inf;
    prm.maxResp=-Inf;
    prm.medianResp=-Inf;
    prm.error='ME';
end