function gk_plotStimulus(ds)
% USAGE: gk_plotStimulus(ds)
%
% This is a function that visualizes the stimulus in time using colored
% bars of different shades for different stimulus intensities
%
% INPUT: ds <- the table returned by gk_datasetQuery
%
% Author: Georgios A. Keliris
%
% See also gk_getCellTimecourse to put neuronal activity on top of stimulus


ds = gk_selectDS(ds);
stim=loadStim(ds);

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
if (strcmpi(ds.cohort,'coh1') || strcmpi(ds.cohort,'coh2')) && strcmpi(ds.expID,'contrast') || strcmpi(ds.expID,'contrast2')
    try
        xline(stim.Times.onsets(1)-1,'b--');
    end
    try
        xline(stim.Times.onsets(141)-1,'b--');
    end
    try
        xline(stim.Times.onsets(281)-1,'b--');
    end
    try
        xline(stim.Times.onsets(421)-1,'b--');
    end
    try
        xline(stim.Times.onsets(end)+4,'b--');
    end
end
legend(num2str(stim.Values),'location','EastOutside')
