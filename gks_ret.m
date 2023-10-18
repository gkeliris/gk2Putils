frame_t=gk_getTimeStamps2P

save frame_t frame_t

h5=gk_readH5('M419_Bar_Left_Right_0001.h5');
stim_t = gk_getStimTimes(h5);
[1 410]


stim_t = gk_getStimFrameTimes(stim_t,frame_t);

stim_t.frame_onsets(1)  % =250
stim_t.frame_offsets(end) %=1924


load('Fall.mat')


Fret=F(:,250:1924);
n=2^nextpow2(1675);
Fs=1675; % whole scan i.e. cycles / scan
f=Fs*(0:(n/2))/n;
Y=fft(Fret,n,2);
P=abs(Y/n).^2;
theta=angle(Y);
for c=1:1788; med(c,:)=stat{c}.med; end
plot3(med(:,2),med(:,1),theta(:,13),'.')