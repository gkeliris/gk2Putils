function coeff = gk_getCoeffs(xpr)

names=coeffnames(xpr.tuning_params{1}.f);
for n = 1:numel(names)
    coeff.(names{n})= cellfun(@(x) x.f.(names{n}), xpr.tuning_params);
end