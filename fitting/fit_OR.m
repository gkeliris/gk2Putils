function prm = fit_OR(stim,sig,fitChoice)
% USAGE: prm = fit_OR(stim,sig,fitChoice)
%
% utility function to fit orientation (OR) responses

if nargin<3
    fitChoice='mean';
end

prm.fitChoice = fitChoice;
prm.maxResp = max(0,max(double(sig.Mean)));
prm.medianResp = median(double(sig.Mean));
prm.ft = fittype('f0+f1*exp(Kappa*(cos(deg2rad(x-Phi))-1))+f1*exp(Kappa*(cos(deg2rad(x-Phi+180))-1))');
prm.ftopt = fitoptions('Method','NonlinearLeastSquares','Robust','Bisquare','Display','off',...
    'Lower',[0,0,-Inf,0],'Upper',[10,180,Inf,Inf],'StartPoint',[1,90.5,-0.5,1]);
if strcmp(fitChoice,'wgt')
    prm.ftopt.Weights=[1./sig.Std.^2; 1./sig.Std.^2]';
end
try
    [prm.f, prm.gof] = fit([stim.Values'; stim.Values'+180],double([sig.Mean'; sig.Mean']), prm.ft, prm.ftopt);
    if strcmp(fitChoice,'all')
        prm.ftopt.StartPoint=[prm.f.Kappa, prm.f.Phi, prm.f.f0, prm.f.f1, prm.f.f2];
        [prm.f, prm.gof]= fit([stim.ValuesNtrials'; stim.ValuesNtrials'+180],double([sig.Trials'; sig.Trials']), prm.ft, prm.ftopt);
    end
catch ME
    xpr.tuning_params{cellNum}.gof.adjrsquare=-Inf;
    xpr.tuning_params{cellNum}.gof.rsquare=-Inf;
    xpr.tuning_params{cellNum}.maxResp=-Inf;
    xpr.tuning_params{cellNum}.medianResp=-Inf;
    xpr.tuning_params{cellNum}.error='ME';
end