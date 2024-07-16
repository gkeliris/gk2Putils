function [response] = ComputeSuperNakaRushton(params,contrast)

if (length(params) == 4)
    A = params(1);
    sigma = params(2);
    %n exponent
    exponent_n = params(3);
    %s exponent
    exponent_s = params(4); 
else
    error('Inproper format, put input parameter as [R_max c50 n s]');
end

% Check for bad contrast input
if (any(contrast < 0))
    error('Cannot deal with negative contrast');
end

% Handle really weird parameter values
if (sigma < 0 || exponent_n < 0 || exponent_s < 0)
    response = -1*ones(size(contrast));
else

    % Now pump the linear response through a non-linearity
    expContrast = (contrast).^exponent_n;
    expContrast1 = contrast.^(exponent_n*exponent_s);
    sigma1 = sigma.^(exponent_n*exponent_s);
    response = A*(expContrast ./ (expContrast1 + sigma1));
end
