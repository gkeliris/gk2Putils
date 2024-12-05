slct_WT = prmsWT(prmsWT.rSquared(:,1)>0.6,:);
slct_TG = prmsTG(prmsTG.rSquared(:,1)>0.6,:);
[h_WT, e] = hist(slct_WT.C50(:,1),20); h_WT = h_WT/sum(h_WT);
h_TG = hist(slct_TG.C50(:,1),20); h_TG = h_TG/sum(h_TG);
bar(e,[h_WT; h_TG]')
legend('show')

figure;
plot(e,[h_WT; h_TG]')

figure;
cdfplot(slct_WT.C50(:,1));
hold on;
cdfplot(slct_TG.C50(:,1));
xlabel('C_5_0 [%]'); ylabel('Cumulative probability'); 
xlim([0 99.9])
legend('WT', 'MeCP2')

figure;
cdfplot(slct_WT.Rmax(:,1));
hold on;
cdfplot(slct_TG.Rmax(:,1));
xlabel('R_m_a_x [%]'); ylabel('Cumulative probability'); 
xlim([0 9.9])
legend('WT', 'MeCP2')

figure;
cdfplot(slct_WT.n(:,1));
hold on;
cdfplot(slct_TG.n(:,1));
xlabel('parameter n'); ylabel('Cumulative probability'); 
xlim([0 19.9])
legend('WT', 'MeCP2')

figure;
cdfplot(slct_WT.s(:,1));
hold on;
cdfplot(slct_TG.s(:,1));
xlabel('parameter s'); ylabel('Cumulative probability'); 
xlim([1.01 2.5])
legend('WT', 'MeCP2')