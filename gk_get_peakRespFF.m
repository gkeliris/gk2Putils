function xpr = gk_get_peakRespFF(xpr)

sigMean = cellfun(@(x) squeeze(mean(x(:,:,:),3)'),xpr.sorted_trials_dF_F,...
                                                'UniformOutput',false);
ti0=find(xpr.t==0);
Fs=1/diff(xpr.t(1:2));

% estimate the standard deviation of the baseline by concatenating all the
% points from the baseline window
bsl=xpr.trials_dF_F(:,ti0-4:ti0,:);
bsl=reshape(bsl,size(bsl,1),size(bsl,2)*size(bsl,3));
bslSTD=std(bsl,1,2);                               

%convert the trials to z-scores by deviding with the std of the baseline
xpr.sorted_trials_Zscore = cellfun(@(x) ...
    x./repmat(bslSTD,1,size(x,2),size(x,3)),xpr.sorted_trials_dF_F,...
    'UniformOutput',false);

% sigMeanZ = cellfun(@(x) squeeze(mean(x(:,:,:),3)'),xpr.sorted_trials_Zscore,...
%                                                 'UniformOutput',false);
tZwindow=xpr.t>0.5;                                            
Z_thresh=3;
zMeanTrialsMax=cellfun(@(x) max(mean(x(:,tZwindow,:),3),[],2), xpr.sorted_trials_Zscore, 'UniformOutput', false);
v = cell2mat(cellfun(@(x) x>=Z_thresh, zMeanTrialsMax, 'UniformOutput',false));
v=reshape(v,numel(xpr.cellIDs),size(xpr.sorted_trials,1),size(xpr.sorted_trials,2));
xpr.zCrossSumMax=max(squeeze(sum(v,2)),[],2);
xpr.visRespCells=find(xpr.zCrossSumMax>1);
xpr.visRespROIs=xpr.cellIDs(xpr.visRespCells);

%% find the peaks (use the average of trials per condition)
tiPeak = xpr.t>-0.5;
tiPeak_ind=find(tiPeak);
h = waitbar(0, 'Finding peaks...');
for c=1:numel(xpr.visRespCells) %  1:numel(xpr.cellIDs)
    waitbar(c/numel(xpr.visRespCells),h,sprintf('Finding peaks (neuron: %d/%d)',c,numel(xpr.visRespCells)));
    [pk, loc, p, w] = cellfun(@(x) findpeaks(x(tiPeak,xpr.visRespCells(c)),'SortStr','descend'...
                               ,'MinPeakDistance',2/Fs,'Npeaks',1,...
                               'MinPeakProminence',0.1),...
                               sigMean,'UniformOutput',false);
     for i=find(cellfun(@isempty,pk))'
         pk{i}=single(nan);
         loc{i}=nan;
         p{i}=nan;
         w{i}=single(nan);
     end
     visRespCells.pk(c,:,:)=cell2mat(pk);
     visRespCells.p(c,:,:)=cell2mat(p);
     visRespCells.w(c,:,:)=cell2mat(w);      
     M=squeeze(max(visRespCells.pk(c,:,:),[],2));
     [~,visRespCells.pref(c)]=max(M);
     visRespCells.loc(c,:,:)=cell2mat(loc);
     visRespCells.loc_pref(c,:)=visRespCells.loc(c,:,visRespCells.pref(c));
     visRespCells.peak_ind(c)=tiPeak_ind(ceil(nanmedian(visRespCells.loc_pref(c,:)')));
     trials = cellfun(@(x) squeeze(mean(x(xpr.visRespCells(c),visRespCells.peak_ind(c)-1:visRespCells.peak_ind(c)+1,:),2)),...
         xpr.sorted_trials_dF_F,'UniformOutput',false);
     xpr.peakPref(c)= visRespCells.pref(c);
     xpr.peakResp_trials{c} = trials;
     xpr.peakResp_mean(c,:,:) = cellfun(@(x) mean(x), trials);
     xpr.peakResp_sem(c,:,:) = cellfun(@(x) std(x)/sqrt(numel(x)), trials);
     
     
%      visRespCells.responses(c,:,:)=cell2mat(trials(:,visRespCells.pref(c))');
%      CRF.sigMean(c,:)=squeeze(mean(visRespCells.responses(c,:,:),2));
%      CRF.sigSem(c,:)=squeeze(std(visRespCells.responses(c,:,:),0,2)./...
%          sqrt(size(visRespCells.responses(c,:,:),2)));
%      [~,maxInd]=max(CRF.sigMean(c,:),[],2);
%      if maxInd<=7
%          CRF.lowCon(c,1)=1;
%      else
%          CRF.lowCon(c,1)=0;
%      end
end
% CRF.lowSum=sum(CRF.lowCon);
% CRF.lowPerc=CRF.lowSum/numel(CRF.lowCon)*100;
% CRF.roiNums=xpr.visRespCells;
% CRF.stimValues=xpr.stimValues;
delete(h)








