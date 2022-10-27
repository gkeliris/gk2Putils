addpath('/media/katerinakalemaki/Elements1/Learning_data/young/testing/npy-matlab');
keldir='/media/katerinakalemaki/Elements1/Learning_data/Keliris/';
cd(keldir)
gks_LRN_paths;

%% M1(Sofoklis)
% Day 1
h5=h5read(pth.M1.D1.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M1.D1.L.p,'/suite2p/combined/Fneu.npy'));

D1=mean(Fneu);
L.M1.D1.mFneu=D1;
t=linspace(1,length(D1),length(h5));

h=figure; set(h,'Name','Sofoklis - D1')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M1.D1.mFneu);
legend('photodiode','mean Fneu');
title('M1(Sofoklis) D1');
savefig(h,fullfile(keldir,'M1_D1_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M1_D1_mFneu_PD'),'png')
close(h)

% Day 5
h5=h5read(pth.M1.D5.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M1.D5.L.p,'/suite2p/combined/Fneu.npy'));

D5=mean(Fneu);
L.M1.D5.mFneu=D5;
t=linspace(1,length(D5),length(h5));

h=figure; set(h,'Name','Sofoklis - D1')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M1.D5.mFneu);
legend('photodiode','mean Fneu');
title('M1(Sofoklis) D5');
savefig(h,fullfile(keldir,'M1_D5_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M1_D5_mFneu_PD'),'png')
close(h)

% Day 6
h5=h5read(pth.M1.D6.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M1.D6.L.p,'/suite2p/combined/Fneu.npy'));

D6=mean(Fneu);
L.M1.D6.mFneu=D6;
t=linspace(1,length(D6),length(h5));

h=figure; set(h,'Name','Sofoklis - D6')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M1.D6.mFneu);
legend('photodiode','mean Fneu');
title('M1(Sofoklis) D6');
savefig(h,fullfile(keldir,'M1_D6_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M1_D6_mFneu_PD'),'png')
close(h)

%% M2(Creon)

% Day 1
h5=h5read(pth.M2.D1.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M2.D1.L.p,'/suite2p/combined/Fneu.npy'));
F=readNPY(fullfile(pth.M2.D1.L.p,'/suite2p/combined/F.npy'));
isc=readNPY(fullfile(pth.M2.D1.L.p,'/suite2p/combined/iscell.npy'));
S=readNPY(fullfile(pth.M2.D1.L.p,'/suite2p/combined/spks.npy'));

N_D1=mean(Fneu(find(isc(:,1)),:));
F_D1=mean(F(find(isc(:,1)),:));
S_D1=mean(S(find(isc(:,1)),:));
L.M2.D1.mFneu=N_D1;

t=linspace(1,length(N_D1),length(h5));

h=figure; set(h,'Name','Creon - D1')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M2.D1.mFneu);
legend('photodiode','mean Fneu');
title('M2(Creon) D1');
savefig(h,fullfile(keldir,'M2_D1_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M2_D1_mFneu_PD'),'png')
close(h)
%plot(D1); % define the trial starts manually at this point
L.M2.D1.trialstart=[710 1093 1476 1859 2242];
for i=1:5; L.M2.D1.trials(i,:)=L.M2.D1.mFneu(L.M2.D1.trialstart(i)-99:L.M2.D1.trialstart(i)+150); end
for i=1:5; 
    Fgray=mean(L.M2.D1.mFneu(L.M2.D1.trialstart(i)-99:L.M2.D1.trialstart(i)));
    %Fstim=mean(L.M2.D1.mFneu(L.M2.D1.trialstart(i)+1:L.M2.D1.trialstart(i)+120));
    L.M2.D1.dF_F(i,:)=(L.M2.D1.trials(i,:)-Fgray)/Fgray;
end

h=figure; set(h,'Name','Creon-D1 trials Fneu');
subplot(2,1,1); hold on;
plot(L.M2.D1.trials','b--')
subplot(2,1,2); hold on;
errorbar(mean(L.M2.D1.trials),std(L.M2.D1.trials,0,1)./sqrt(size(L.M2.D1.trials,1)),'b');
suptitle('M2(Creon) D1 trials - dFneu/Fneu')
savefig(h,fullfile(keldir,'M2_D1_trials_mFneu.fig'))
saveas(h,fullfile(keldir,'M2_D1_trials_mFneu'),'png')
close(h);

h1=figure; %set(h1,'Name','Creon-D1 trials dFneu/Fneu');
subplot(2,1,1); hold on;
plot(L.M2.D1.dF_F','b--')
subplot(2,1,2); hold on;
errorbar(mean(L.M2.D1.dF_F),std(L.M2.D1.dF_F,0,1)./sqrt(size(L.M2.D1.dF_F,1)),'b');
%suptitle('M2(Creon) D1 trials - dFneu/Fneu')
savefig(h1,fullfile(keldir,'M2_D1_trials_dFneu_Fneu.fig'))
saveas(h1,fullfile(keldir,'M2_D1_trials_dFneu_Fneu'),'png')
%close(h);

% Day 5
h5=h5read(pth.M2.D5.L.h5.p,'/sweep_0002/analogScans');
Fneu=readNPY(fullfile(pth.M2.D5.L.p,'/suite2p/combined/Fneu.npy'));

D5=mean(Fneu);
L.M2.D5.mFneu=D5;
t=linspace(1,length(D5),length(h5));

h=figure; set(h,'Name','Creon - D5')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M2.D5.mFneu);
legend('photodiode','mean Fneu');
title('M2(Creon) D5');
savefig(h,fullfile(keldir,'M2_D5_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M2_D5_mFneu_PD'),'png')
close(h)
%plot(D5);
L.M2.D5.trialstart=[542 925 1305 1690 2073];
for i=1:5; L.M2.D5.trials(i,:)=L.M2.D5.mFneu(L.M2.D5.trialstart(i)-99:L.M2.D5.trialstart(i)+150); end
for i=1:5; 
    Fgray=mean(L.M2.D5.mFneu(L.M2.D5.trialstart(i)-99:L.M2.D5.trialstart(i)));
    Fstim=mean(L.M2.D5.mFneu(L.M2.D5.trialstart(i)+1:L.M2.D5.trialstart(i)+120));
    L.M2.D5.dF_F(i,:)=(L.M2.D5.trials(i,:)-Fgray)/Fgray;
end

figure(h1); %set(h1,'Name','Creon-D1 vs D5 trials dFneu/Fneu');
subplot(2,1,1); hold on;
plot(L.M2.D5.dF_F','r--')
ylabel('\DeltaF/F')
subplot(2,1,2); hold on;
errorbar(mean(L.M2.D5.dF_F),std(L.M2.D5.dF_F,0,1)./sqrt(size(L.M2.D5.dF_F,1)),'r');
ylabel('\DeltaF/F')
xlabel('time [frames]')
legend('D1','D5')
suptitle('M2(Creon) D1 vs D5 trials - dFneu/Fneu')
savefig(h1,fullfile(keldir,'M2_D1_D5_trials_dFneu_Fneu.fig'))
saveas(h1,fullfile(keldir,'M2_D1_D5_trials_dFneu_Fneu'),'png')

% Day 6
load('/media/katerinakalemaki/Elements/Creon/Day6_learning_nov_fam/MB_novfam_0001.mat','stims'); % 1=45 (familiar), 2=135

h5=h5read(pth.M2.D6.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M2.D6.L.p,'/suite2p/combined/Fneu.npy'));
F=readNPY(fullfile(pth.M2.D6.L.p,'/suite2p/combined/F.npy'));
isc=readNPY(fullfile(pth.M2.D6.L.p,'/suite2p/combined/iscell.npy'));
S=readNPY(fullfile(pth.M2.D6.L.p,'/suite2p/combined/spks.npy'));

%D6=mean(Fneu);
N_D6=mean(Fneu(find(isc(:,1)),:));
F_D6=mean(F(find(isc(:,1)),:));
S_D6=mean(S(find(isc(:,1)),:));
L.M2.D6.mFneu=N_D6;
L.M2.D6.mF=F_D6;
L.M2.D6.mS=S_D6;
t=linspace(1,length(N_D6),length(h5));

h=figure; set(h,'Name','Creon - D6')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M2.D6.mFneu); plot(F_D6); plot(S_D6);
legend('photodiode','mean Fneu','F','Spikes');
title('M2(Creon) D6');
savefig(h,fullfile(keldir,'M2_D6_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M2_D6_mFneu_PD'),'png')
close(h)
%plot(D6);
trialstart=[706 1089 1471 1853 2237 2620 3008 3386 3768 4146 nan*zeros(1,10)];
L.M2.D6.trialstartFam=trialstart(find(stims==1)); % There is more but actually only 5 were presented before a crash
L.M2.D6.trialstartNov=trialstart(find(stims==2)); % There is more but actually only 5 were presented before a crash

for i=1:5; L.M2.D6.trialsFam(i,:)=L.M2.D6.mFneu(L.M2.D6.trialstartFam(i)-99:L.M2.D6.trialstartFam(i)+150); end
for i=1:5; L.M2.D6.trialsNov(i,:)=L.M2.D6.mFneu(L.M2.D6.trialstartNov(i)-99:L.M2.D6.trialstartNov(i)+150); end
for i=1:5; L.M2.D6.F.trialsFam(i,:)=L.M2.D6.mF(L.M2.D6.trialstartFam(i)-99:L.M2.D6.trialstartFam(i)+150); end
for i=1:5; L.M2.D6.F.trialsNov(i,:)=L.M2.D6.mF(L.M2.D6.trialstartNov(i)-99:L.M2.D6.trialstartNov(i)+150); end
for i=1:5; L.M2.D6.S.trialsFam(i,:)=L.M2.D6.mS(L.M2.D6.trialstartFam(i)-99:L.M2.D6.trialstartFam(i)+150); end
for i=1:5; L.M2.D6.S.trialsNov(i,:)=L.M2.D6.mS(L.M2.D6.trialstartNov(i)-99:L.M2.D6.trialstartNov(i)+150); end


h=figure; set(h,'Name','Creon-D6 trials');
subplot(2,1,1); hold on;
plot(L.M2.D6.trialsFam','b--')
plot(L.M2.D6.trialsNov','r--')
subplot(2,1,2); hold on;
errorbar(mean(L.M2.D6.trialsFam),std(L.M2.D6.trialsFam,0,1)./sqrt(size(L.M2.D6.trialsFam,1)),'b');
errorbar(mean(L.M2.D6.trialsNov),std(L.M2.D6.trialsNov,0,1)./sqrt(size(L.M2.D6.trialsNov,1)),'r');
legend('familiar','novel')
suptitle('M2(Creon) D6 trials')
savefig(h,fullfile(keldir,'M2_D6_fam_nov_trials.fig'))
saveas(h,fullfile(keldir,'M2_D6_fam_nov_trials'),'png')
close(h);

h=figure; set(h,'Name','Creon-D6 trials');
subplot(2,1,1); hold on;
plot(L.M2.D6.F.trialsFam','b--')
plot(L.M2.D6.F.trialsNov','r--')
subplot(2,1,2); hold on;
errorbar(mean(L.M2.D6.F.trialsFam),std(L.M2.D6.F.trialsFam,0,1)./sqrt(size(L.M2.D6.F.trialsFam,1)),'b');
errorbar(mean(L.M2.D6.F.trialsNov),std(L.M2.D6.F.trialsNov,0,1)./sqrt(size(L.M2.D6.F.trialsNov,1)),'r');
legend('familiar','novel')
suptitle('M2(Creon) D6 trials - mean F')
savefig(h,fullfile(keldir,'M2_D6_fam_nov_trials_F.fig'))
saveas(h,fullfile(keldir,'M2_D6_fam_nov_trials_F'),'png')
close(h);

h=figure; set(h,'Name','Creon-D6 trials Spikes');
subplot(2,1,1); hold on;
plot(L.M2.D6.S.trialsFam','b--')
plot(L.M2.D6.S.trialsNov','r--')
subplot(2,1,2); hold on;
errorbar(mean(L.M2.D6.S.trialsFam),std(L.M2.D6.S.trialsFam,0,1)./sqrt(size(L.M2.D6.S.trialsFam,1)),'b');
errorbar(mean(L.M2.D6.S.trialsNov),std(L.M2.D6.S.trialsNov,0,1)./sqrt(size(L.M2.D6.S.trialsNov,1)),'r');
legend('familiar','novel')
suptitle('M2(Creon) D6 trials - Spikes')
savefig(h,fullfile(keldir,'M2_D6_fam_nov_trials_S.fig'))
saveas(h,fullfile(keldir,'M2_D6_fam_nov_trials_S'),'png')
close(h);
%% M3(Lakis)

% Day 1
h5=h5read(pth.M3.D1.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M3.D1.L.p,'/suite2p/combined/Fneu.npy'));

D1=mean(Fneu);
L.M3.D1.mFneu=D1;
t=linspace(1,length(D1),length(h5));

h=figure; set(h,'Name','Lakis - D1')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M3.D1.mFneu);
legend('photodiode','mean Fneu');
title('M3(Lakis) D1');
savefig(h,fullfile(keldir,'M3_D1_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M3_D1_mFneu_PD'),'png')
close(h)
%plot(D1); % define the trial starts manually at this point
L.M3.D1.trialstart=[648 995 1338 1687 2032];
for i=1:5; L.M3.D1.trials(i,:)=L.M3.D1.mFneu(L.M3.D1.trialstart(i)-99:L.M3.D1.trialstart(i)+150); end
for i=1:5; 
    Fgray=mean(L.M3.D1.mFneu(L.M3.D1.trialstart(i)-99:L.M3.D1.trialstart(i)));
    %Fstim=mean(L.M3.D1.mFneu(L.M3.D1.trialstart(i)+1:L.M3.D1.trialstart(i)+120));
    L.M3.D1.dF_F(i,:)=(L.M3.D1.trials(i,:)-Fgray)/Fgray;
end

h1=figure; %set(h1,'Name','Lakis-D1 trials dFneu/Fneu');
subplot(2,1,1); hold on;
plot(L.M3.D1.dF_F','b--')
subplot(2,1,2); hold on;
errorbar(mean(L.M3.D1.dF_F),std(L.M3.D1.dF_F,0,1)./sqrt(size(L.M3.D1.dF_F,1)),'b');
%suptitle('M3(Lakis) D1 trials - dFneu/Fneu')
savefig(h1,fullfile(keldir,'M3_D1_trials_dFneu_Fneu.fig'))
saveas(h1,fullfile(keldir,'M3_D1_trials_dFneu_Fneu'),'png')

% Day 5
h5=h5read(pth.M3.D5.L.h5.p,'/sweep_0002/analogScans');
Fneu=readNPY(fullfile(pth.M3.D5.L.p,'/suite2p/combined/Fneu.npy'));

D5=mean(Fneu);
L.M3.D5.mFneu=D5;
t=linspace(1,length(D5),length(h5));


h=figure; set(h,'Name','Lakis - D5')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M3.D5.mFneu);
legend('photodiode','mean Fneu');
title('M3(Lakis) D5');
savefig(h,fullfile(keldir,'M3_D5_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M3_D5_mFneu_PD'),'png')
close(h)
%plot(D5);
L.M3.D5.trialstart=[631 980 1328 1676 2024];
for i=1:5; L.M3.D5.trials(i,:)=L.M3.D5.mFneu(L.M3.D5.trialstart(i)-99:L.M3.D5.trialstart(i)+150); end
for i=1:5; 
    Fgray=mean(L.M3.D5.mFneu(L.M3.D5.trialstart(i)-99:L.M3.D5.trialstart(i)));
    %Fstim=mean(L.M3.D5.mFneu(L.M3.D5.trialstart(i)+1:L.M3.D5.trialstart(i)+120));
    L.M3.D5.dF_F(i,:)=(L.M3.D5.trials(i,:)-Fgray)/Fgray;
end

figure(h1); %set(h,'Name','Lakis-D1 vs D5 trials dFneu/Fneu');
subplot(2,1,1); hold on;
plot(L.M3.D5.dF_F','r--')
ylabel('\DeltaF/F')
subplot(2,1,2); hold on;
errorbar(mean(L.M3.D5.dF_F),std(L.M3.D5.dF_F,0,1)./sqrt(size(L.M3.D5.dF_F,1)),'r');
ylabel('\DeltaF/F')
xlabel('time [frames]')
legend('D1','D5')
suptitle('M3(Lakis) D1 vs D5 trials - dFneu/Fneu')
savefig(h1,fullfile(keldir,'M3_D1_D5_trials_dFneu_Fneu.fig'))
saveas(h1,fullfile(keldir,'M3_D1_D5_trials_dFneu_Fneu'),'png')


% Day 6
load('/media/katerinakalemaki/Elements/Lakis/Day6_learning_NovFam_05_30_21/MB_novfam_0001.mat','stims'); % 1=45, 2=135 (familiar)

h5=h5read(pth.M3.D6.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M3.D6.L.p,'/suite2p/combined/Fneu.npy'));

D6=mean(Fneu);
L.M3.D6.mFneu=D6;
t=linspace(1,length(D6),length(h5));

h=figure; set(h,'Name','Lakis - D6')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M3.D6.mFneu);
legend('photodiode','mean Fneu');
title('M3(Lakis) D6');
savefig(h,fullfile(keldir,'M3_D6_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'M3_D6_mFneu_PD'),'png')
close(h)
%plot(D6);
trialstarts=[642 990 1347 1695 2044 2392 2740 3088 3427 3794 4133 4480 4829 5161 5508 5872 6220 6567 6918 7266];
L.M3.D6.trialstartFam=trialstarts(find(stims==2));
L.M3.D6.trialstartNov=trialstarts(find(stims==1));
for i=1:10; L.M3.D6.trialsFam(i,:)=L.M3.D6.mFneu(L.M3.D6.trialstartFam(i)-99:L.M3.D6.trialstartFam(i)+150); end
for i=1:10; L.M3.D6.trialsNov(i,:)=L.M3.D6.mFneu(L.M3.D6.trialstartNov(i)-99:L.M3.D6.trialstartNov(i)+150); end


h=figure; set(h,'Name','Lakis-D6 trials');
subplot(2,1,1); hold on;
plot(L.M3.D6.trialsFam','b--')
plot(L.M3.D6.trialsNov','r--')
subplot(2,1,2); hold on;
errorbar(mean(L.M3.D6.trialsFam),std(L.M3.D6.trialsFam,0,1)./sqrt(size(L.M3.D6.trialsFam,1)),'b');
errorbar(mean(L.M3.D6.trialsNov),std(L.M3.D6.trialsNov,0,1)./sqrt(size(L.M3.D6.trialsNov,1)),'r');
legend('familiar','novel')
suptitle('M3(Lakis) D6 trials')
savefig(h,fullfile(keldir,'M3_D6_fam_nov_trials.fig'))
saveas(h,fullfile(keldir,'M3_D6_fam_nov_trials'),'png')
close(h);

%% M4(Marilou)

% Day 1
h5=h5read(pth.M4.D1.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M4.D1.L.p,'/suite2p/combined/Fneu.npy'));

D1=mean(Fneu);
L.M4.D1.mFneu=D1;
t=linspace(1,length(D1),length(h5));

h=figure; set(h,'Name','Marilou - D1')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M4.D1.mFneu);
legend('photodiode','mean Fneu');
title('M4(Marilou) D1');
savefig(h,fullfile(keldir,'Figures','FIG','M4_D1_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'Figures','PNG','M4_D1_mFneu_PD'),'png')
close(h)
%plot(D1); % define the trial starts manually at this point
L.M4.D1.trialstart=[1190 1828 2468 3104 3742];
for i=1:5; L.M4.D1.trials(i,:)=L.M4.D1.mFneu(L.M4.D1.trialstart(i)-99:L.M4.D1.trialstart(i)+250); end
for i=1:5; 
    Fgray=mean(L.M4.D1.mFneu(L.M4.D1.trialstart(i)-99:L.M4.D1.trialstart(i)));
    %Fstim=mean(L.M3.D1.mFneu(L.M3.D1.trialstart(i)+1:L.M3.D1.trialstart(i)+120));
    L.M4.D1.dF_F(i,:)=(L.M4.D1.trials(i,:)-Fgray)/Fgray;
end

h1=figure; %set(h1,'Name','Marilou-D1 trials dFneu/Fneu');
subplot(2,1,1); hold on;
plot(L.M4.D1.dF_F','b--')
subplot(2,1,2); hold on;
errorbar(mean(L.M4.D1.dF_F),std(L.M4.D1.dF_F,0,1)./sqrt(size(L.M4.D1.dF_F,1)),'b');
%suptitle('M4(Marilou) D1 trials - dFneu/Fneu')
savefig(h1,fullfile(keldir,'Figures','FIG','M4_D1_trials_dFneu_Fneu.fig'))
saveas(h1,fullfile(keldir,'Figures','PNG','M4_D1_trials_dFneu_Fneu'),'png')

% Day 5
h5=h5read(pth.M4.D5.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M4.D5.L.p,'/suite2p/combined/Fneu.npy'));

D5=mean(Fneu);
L.M4.D5.mFneu=D5;
t=linspace(1,length(D5),length(h5));


h=figure; set(h,'Name','Marilou - D5')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M4.D5.mFneu);
legend('photodiode','mean Fneu');
title('M4(Marilou) D5');
savefig(h,fullfile(keldir,'Figures','FIG','M4_D5_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'Figures','PNG','M4_D5_mFneu_PD'),'png')
close(h)
%plot(D5);
L.M4.D5.trialstart=[1187 1825 2463 3095 3737];
for i=1:5; L.M4.D5.trials(i,:)=L.M4.D5.mFneu(L.M4.D5.trialstart(i)-99:L.M4.D5.trialstart(i)+250); end
for i=1:5; 
    Fgray=mean(L.M4.D5.mFneu(L.M4.D5.trialstart(i)-99:L.M4.D5.trialstart(i)));
    %Fstim=mean(L.M3.D5.mFneu(L.M3.D5.trialstart(i)+1:L.M3.D5.trialstart(i)+120));
    L.M4.D5.dF_F(i,:)=(L.M4.D5.trials(i,:)-Fgray)/Fgray;
end

figure(h1); %set(h,'Name','Lakis-D1 vs D5 trials dFneu/Fneu');
subplot(2,1,1); hold on;
plot(L.M4.D5.dF_F','r--')
ylabel('\DeltaF/F')
subplot(2,1,2); hold on;
errorbar(mean(L.M4.D5.dF_F),std(L.M4.D5.dF_F,0,1)./sqrt(size(L.M4.D5.dF_F,1)),'r');
ylabel('\DeltaF/F')
xlabel('time [frames]')
legend('D1','D5')
suptitle('M4(Marilou) D1 vs D5 trials - dFneu/Fneu')
savefig(h1,fullfile(keldir,'Figures','FIG','M4_D1_D5_trials_dFneu_Fneu.fig'))
saveas(h1,fullfile(keldir,'Figures','PNG','M4_D1_D5_trials_dFneu_Fneu'),'png')


% Day 6
load('/media/katerinakalemaki/Elements/Marilou/07_28_21_Learning_Fam_Novel_Day6/MB_novfam_0001.mat','stims'); % 1=45, 2=135 (familiar)

h5=h5read(pth.M4.D6.L.h5.p,'/sweep_0001/analogScans');
Fneu=readNPY(fullfile(pth.M4.D6.L.p,'/suite2p/combined/Fneu.npy'));

D6=mean(Fneu);
L.M4.D6.mFneu=D6;
t=linspace(1,length(D6),length(h5));

h=figure; set(h,'Name','Marilou - D6')
plot(t,h5(:,2)); % photodiode
hold on; plot(L.M4.D6.mFneu);
legend('photodiode','mean Fneu');
title('M4(Marilou) D6');
savefig(h,fullfile(keldir,'Figures','FIG','M3_D6_mFneu_PD.fig'))
saveas(h,fullfile(keldir,'Figures','PNG','M3_D6_mFneu_PD'),'png')
close(h)
%plot(D6);
trialstarts=[642 990 1347 1695 2044 2392 2740 3088 3427 3794 4133 4480 4829 5161 5508 5872 6220 6567 6918 7266];
L.M3.D6.trialstartFam=trialstarts(find(stims==2));
L.M3.D6.trialstartNov=trialstarts(find(stims==1));
for i=1:10; L.M3.D6.trialsFam(i,:)=L.M3.D6.mFneu(L.M3.D6.trialstartFam(i)-99:L.M3.D6.trialstartFam(i)+150); end
for i=1:10; L.M3.D6.trialsNov(i,:)=L.M3.D6.mFneu(L.M3.D6.trialstartNov(i)-99:L.M3.D6.trialstartNov(i)+150); end


h=figure; set(h,'Name','Lakis-D6 trials');
subplot(2,1,1); hold on;
plot(L.M3.D6.trialsFam','b--')
plot(L.M3.D6.trialsNov','r--')
subplot(2,1,2); hold on;
errorbar(mean(L.M3.D6.trialsFam),std(L.M3.D6.trialsFam,0,1)./sqrt(size(L.M3.D6.trialsFam,1)),'b');
errorbar(mean(L.M3.D6.trialsNov),std(L.M3.D6.trialsNov,0,1)./sqrt(size(L.M3.D6.trialsNov,1)),'r');
legend('familiar','novel')
suptitle('M3(Lakis) D6 trials')
savefig(h,fullfile(keldir,'M3_D6_fam_nov_trials.fig'))
saveas(h,fullfile(keldir,'M3_D6_fam_nov_trials'),'png')
close(h);



