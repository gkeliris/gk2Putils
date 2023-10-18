load('genotypes.mat');
d=dir('*CRF.mat');
for i=1:numel(d)
    load(d(i).name)
    splitStr=regexp(d(i).name,'_','split');
    cohort{i,1}=splitStr{1};
    timepoint{i,1}=splitStr{2};
    mouse{i,1}=splitStr{3};
    nTuned(i,1)=numel(CRF.lowCon);
    nLowContrast(i,1)=CRF.lowSum;
    percLowContrast(i,1)=CRF.lowPerc;
    if ~isempty(find(strcmp(genotype.(cohort{i}).tg,mouse{i})))
        GenType{i,1}='tg';
    else
        GenType{i,1}='wt';
    end
end
data=table([mouse],GenType,cohort,timepoint,nTuned,nLowContrast,percLowContrast);