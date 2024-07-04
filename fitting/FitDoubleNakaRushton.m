function [params,f, R2] = FitDoubleNakaRushton(contrast,response,params0)
% [params,f] = FitNakaRushton(contrast,response [, params0])
%
% Find the parameters that best fit the data.  If the initial guess
% isn't good, this can get stuck in local minima.
%
% 8/1/05    dhb, pr     Wrote it.
% 8/2/07    dhb         Change argument order.
% 7/1/21    dhb         Add end statement for compiler happiness.
%           dhb         Added example at top, which tests that it works.

% Examples:
%{
Rmax = 2; sigma = 0.5; n = 2.4;
params = [Rmax sigma n];
contrast = linspace(0,1,10);
response = ComputeNakaRushton(params,contrast);
fineContrast = linspace(0,1,100);
fitParams = FitNakaRushton(contrast,response);
predict = ComputeNakaRushton(fitParams,fineContrast);
figure; clf; hold on
plot(contrast,response,'ko','MarkerSize',12,'MarkerFaceColor','k');
plot(fineContrast,predict,'k','LineWidth',2);
xlabel('Contrast'); ylabel('Response');
xlim([0 1]); ylim([0 2]);
%}

% If params0 isn't passed, try to pick a good default.
if (nargin < 3 || isempty(params0))
    params0(1) = max(response);
    params0(2) = mean(contrast);
    params0(3) = 2;
    params0(4)= 0;
    params0(5) = 1;
    params0(6) = 2;
end

% Set up minimization options
options = optimset;
options = optimset(options,'Display','off');
if ~IsOctave
    options = optimset(options,'LargeScale','off');
end

% vlb = [0      0.001     0.001 0 0.001 0.001]';
% vub = [1000   100000    100 1000 100000 100]';
vlb = [0  0.001  0.5 0  0.001 0.5]'; %min
vub = [10 1 10  10 1 10]';  %max
params = fmincon(@(params)FitNakaRushtonFun(params,contrast,response),params0,[],[],[],[],vlb,vub,[],options);
[f, R2] = FitNakaRushtonFun(params,contrast,response);

end

% Target function to optimize:
function [f, R2] = FitNakaRushtonFun(params,contrast,response)
% [f] = FitNakaRushtonFun(params)
%
% Evaluate model fit and return measure of goodness of fit (f).
%
% 8/1/05    dhb, pr     Wrote it.
% 8/2/07    dhb         Get rid of silly call to ComputeNakaRushtonError.

% Unpack paramters, make predictions
prediction = ComputeDoubleNakaRushton(params,contrast);
nPoints = length(prediction);
yMean=sum(prediction)/nPoints;
error = prediction-response;
tot = prediction-yMean;
f = 10000*sqrt(sum(error.^2)/nPoints);
RSS=sum(error.^2);
TSS=sum(tot.^2);
R2 = max(0,1-RSS/TSS);

% Handle bizarre parameter values.
if (isnan(f))
    f = 2000;
end

end
