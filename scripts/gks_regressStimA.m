predictor=[stimA.v-median(stimA.v) ones(size(stimA.v))];
for c=1:size(tc,1)
    [RG{c}.B RG{c}.BINT RG{c}.R RG{c}.RINT RG{c}.stats]=regress(tc(c,:)', predictor);
end