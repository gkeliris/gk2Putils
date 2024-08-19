function [params,f, R2] = FitSuperNakaRushton(contrast,response,params0)
% USAGE: [params, f, R2] = FitSuperNakaRushton(contrast,response,params0)
%
% INPUT:
%   contrast :  contrast data points
%   response:   fluorescence data 
%   params0:    optional first guess of parameters
%  
% OUTPUT:
%   params:     paramters [asymptomatic value, c_50, n, s]
%   f:          goodness of fit
%   R2:         R squared term

if (nargin < 3 || isempty(params0))
   %For the Super Naka Rushton, Rmax is not the "max value", but rather
   %the asymptomatic value
    params0(1) = response(end);
    %c_50 value
    params0(2) = mean(contrast);
    %n value
    params0(3) = 2;
    %s value - suppressive exponent
    params0(4) = 1;
end

% Set up minimization options
options = optimset;
options = optimset(options,'Display','off');
if ~IsOctave
    options = optimset(options,'LargeScale','off');
end

%not sure about these upper and lower bounds
vlb = [0  0.001 0.5 .8]';
vub = [10   1  10 2]';
params = fmincon(@(params)FitSuperNakaRushtonFun(params,contrast,response),params0,[],[],[],[],vlb,vub,[],options);
[f, R2] = FitSuperNakaRushtonFun(params,contrast,response);

end

% Target function to optimize:
function [f, R2] = FitSuperNakaRushtonFun(params,contrast,response)
% [f] = FitNakaRushtonFun(params)
%
% Evaluate model fit and return measure of goodness of fit (f).
%
% 8/1/05    dhb, pr     Wrote it.
% 8/2/07    dhb         Get rid of silly call to ComputeNakaRushtonError.

% Unpack paramters, make predictions
prediction = ComputeSuperNakaRushton(params,contrast);
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
