function gk_plotStimulus(coh,wk,ms,ex)
% USAGE: gk_plotStimulus(coh,wk,ms,ex)
%
% Author: Georgios A. Keliris

pth=gk_getDESpath('proc',coh,wk,ms,ex);
load(fullfile(pth,'stim'));


onoff=[stim.Times.onsets, stim.Times.offsets]';
amp=repmat(8096,size(onoff));
N=numel(stim.Values);
figure;
scrsize=get(0,'Screensize');
set(gcf, 'Position',[scrsize(4)*4/5 1 scrsize(3) scrsize(4)/5]);
hold on;
map=colormap(cool(N));
for s=1:N
    ind=find(stim.IDs==s);
    area(onoff(:,ind(1)),amp(:,ind(1)),'FaceColor',[1 0.95-0.95*(s-1)/(N-1) 0.95-0.95*(s-1)/(N-1)],'LineStyle','none')
end
for s=1:N
    ind=find(stim.IDs==s);
    area(onoff(:,ind(2:end)),amp(:,ind(2:end)),'FaceColor',[1 0.95-0.95*(s-1)/(N-1) 0.95-0.95*(s-1)/(N-1)],'LineStyle','none')
end
if (strcmpi(coh,'coh1') || strcmpi('coh2')) && strcmpi(ex,'contrast')
    xline(stim.Times.onsets(1)-1,'b--');
    xline(stim.Times.onsets(141)-1,'b--');
    xline(stim.Times.onsets(281)-1,'b--');
    xline(stim.Times.onsets(421)-1,'b--');
    xline(stim.Times.onsets(end)+4,'b--');
end
legend(num2str(stim.Values),'location','EastOutside')
