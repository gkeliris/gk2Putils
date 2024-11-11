function parameters = gk_plot_tuning(xpr, cellNum, grp, stimValues, xlabelStr)
% USAGE: parameters = gk_plot_tuning(xpr, cellNum, grp, stimValues, [xlabelStr])
%
% Function that plots the tuning function of roi/neuron
%
% Input: xpr - a structure returned by gk_exp_getSigTrials/gk_getTunedROIs
%        cellNum - the number of the cell (not global ROI) in xpr
%        grp - the group number
%        stimValues - the type of stimuli stored in xpr.stimValues
%        xlabelStr - a string to label the x axis (optional)
%
% Output: prm - the fitting parameters
%
% Author: Georgios A. Keliris
% v1.0 - 16 Oct 2022
% v2.0 - 19 Aug 2024
%
% See also FitNakaRushton, ComputeNakaRushton

if nargin == 4
    xlabelStr = 'stimulus parameter';
end

%Ntrials = size(sig.trials_ONresp,2); 
%sigMeanON = squeeze(mean(sig.trials_ONresp(roiNum,:,:),2));
sigMeanON = cellfun(@(x) squeeze(mean(x(cellNum,:),2)),xpr.sorted_trials_ONresp,'UniformOutput',false);
sigMeanON = [sigMeanON{:,grp}];
sigTrialsON = cellfun(@(x) x(cellNum,:),xpr.sorted_trials_ONresp,'UniformOutput',false);
Ntrials = cellfun(@(x) length(x),sigTrialsON,'UniformOutput',false);
Ntrials = [Ntrials{:,grp}];
stimValuesNtrials = [];
for i=1:length(stimValues)
    stimValuesNtrials = [stimValuesNtrials repmat(stimValues(i),1,Ntrials(i))];
end
sigTrialsON = [sigTrialsON{:,grp}];
%sigSemON = squeeze(std(sig.trials_ONresp(roiNum,:,:),0,2)./sqrt(Ntrials));
sigSemON = cellfun(@(x) squeeze(std(x(cellNum,:),0,2)./sqrt(size(x,2))),xpr.sorted_trials_ONresp,'UniformOutput',false);
sigSemON = [sigSemON{:,grp}];
%sigMeanOFF= squeeze(mean(sig.trials_OFFresp(roiNum,:,:),2));
%sigSemOFF = squeeze(std(sig.trials_OFFresp(roiNum,:,:),0,2)./sqrt(Ntrials));

errorbar(stimValues,sigMeanON,sigSemON,'ko','MarkerFaceColor',[0 0 0]);
yline([0],'--');
xlabel(xlabelStr);
%xlim padded
%ylim padded
ylabel('\DeltaF/F');
%title(['ROI#: ' num2str(cellNum)]);
title(['CELL#: ' num2str(cellNum) ', ROI#: ' num2str(xpr.cellIDs(cellNum))]);


switch xpr.expType
    case 'contrast'
        [params,f,R2]= FitSuperNakaRushton(stimValues./100,double(sigMeanON)');
        fineContrast = linspace(0,1,100);
        predict = ComputeSuperNakaRushton(params,fineContrast);
        hold on;
        plot(fineContrast*100,predict,'r','LineWidth',2);
        %In case they just want to plot something
        if nargout > 0
            parameters = [params R2 max(abs(double(sigMeanON)))];
        end
    case 'OR'
%         binangles=round(10000*(sigMeanON-min(sigMeanON))./sum(sigMeanON-min(sigMeanON)));
%         samples=[];
%         for s=1:numel(binangles)
%             samples=[samples; repmat(deg2rad(stimValues(s))-pi,binangles(s),1)];
%         end
%         nComponents = 2;
%         fittedVmm = fitmvmdist(samples, nComponents, ...
%             'MaxIter', 250); % Set maximum number of EM iterations to 250
%         
%         norm = sum(fittedVmm.pdf(unique(samples)));
%         xangles = linspace(-pi, pi, 1000)';
%         hold on;
%         plot(rad2deg(xangles)+180,norm*fittedVmm.pdf(xangles)+min(sigMeanON),'r','LineWidth',1.5);
%         

        %% This is a quick and dirty way to fit the orientation tuning
%         [thetahat kappa] = circ_vmpar(deg2rad(stimValues)*2,sigMeanON'-min(sigMeanON));
%         [p alpha]=circ_vmpdf([],thetahat,kappa);
%         hold on;
%         %plot(rad2deg(alpha)/2,p*sum(sigMeanON-min(sigMeanON))+min(sigMeanON),'r','LineWidth',1.5);
%         plot(alpha,p*sum(sigMeanON-min(sigMeanON))+min(sigMeanON),'r','LineWidth',1.5);
        %% Matlab least squares
        prm.cellNum=cellNum; prm.roiNum=xpr.cellIDs(cellNum);
        prm.ftopt = fitoptions('Method','NonlinearLeastSquares','Robust','on',...
            'Lower',[-Inf,0,0,0],'Upper',[Inf,Inf,Inf,180],'StartPoint',[0,1,1,90]);
        %ft = fittype('f0+f1*exp(kappa*(cos(deg2rad(2*(x-phi)))-1))');
        %f = fit(stimValuesNtrials',double(sigTrialsON'), ft, ftopt);
        prm.ft = fittype('f0+f1*exp(kappa*(cos(deg2rad(x-phi))-1))+f1*exp(kappa*(cos(deg2rad(x-phi+180))-1))');
        [prm.f_init, prm.gof_init] = fit([stimValues; stimValues+180],double([sigMeanON'; sigMeanON']), prm.ft, prm.ftopt);
        prm.ftopt.StartPoint=[prm.f_init.f0, prm.f_init.f1, prm.f_init.kappa, prm.f_init.phi];
        [prm.f, prm.gof]= fit([stimValuesNtrials'; stimValuesNtrials'+180],double([sigTrialsON'; sigTrialsON']), prm.ft, prm.ftopt);
        xlim([-5 175])
        hold on;  plot(prm.f_init,'r'); plot(prm.f,'g');
        xlabel(xlabelStr);
        ylabel('\DeltaF/F');
        
        if nargout > 0
            parameters=prm;
        end
    case 'DR'
        % code for DR tuning
        prm.cellNum=cellNum; prm.roiNum=xpr.cellIDs(cellNum);
        prm.ftopt = fitoptions('Method','NonlinearLeastSquares','Robust','on',...
            'Lower',[-Inf,0,0,0,0],'Upper',[Inf,Inf,Inf,Inf,180],'StartPoint',[1,1,1,1,90]);
        prm.ft = fittype('f0+f1*exp(kappa*(cos(deg2rad(x-phi))-1))+f2*exp(kappa*(cos(deg2rad(x-phi+180))-1))');
        [prm.f_init, prm.gof_init] = fit(stimValues,double(sigMeanON'), prm.ft, prm.ftopt);
        prm.ftopt.StartPoint=[prm.f_init.f0, prm.f_init.f1, prm.f_init.f2, prm.f_init.kappa, prm.f_init.phi];
        [prm.f, prm.gof] = fit(stimValuesNtrials',double(sigTrialsON'), prm.ft, prm.ftopt);
        xlim([-5 355])
        hold on; plot(prm.f_init,'r--'); plot(prm.f,'g');
        xlabel(xlabelStr);
        ylabel('\DeltaF/F');
        if nargout > 0
            parameters=prm;
        end
    case 'OO'
        % code for OO tuning
    case 'SF'
        % code for SF tuning
    case 'TF'
        % code for TF tuning
    otherwise
        error('Unknown experiment type');
end







return