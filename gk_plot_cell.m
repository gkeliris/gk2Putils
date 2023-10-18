function gk_plot_cell(xpr,cellNum,shadedError)

multiGrp=false;
switch xpr.expType
    case 'contrast'
        xlabl='Contrast [%]';
        multiGrp=true;
    case 'OR'
        xlabl='orientation [deg]';
    case 'DR'
        xlabl='direction [deg]';
    case 'OO'
        xlabl='responses to black(0) or white(1)';
    case 'SF'
        xlabl='SF [cycles/deg]';
        multiGrp=true;
    case 'TF'
        xlabl='TF [cycles/s]';
        multiGrp=true;
    otherwise
        xlabl='arbritrary units';
end


if multiGrp
    angles={'0','90','120','210'};
    
    for g=1:numel(xpr.grp)
        subplot(2,4,2*(g-1)+1);
        gk_plot_trials(xpr, cellNum, g, xpr.stimValues, shadedError)
        
        title(['CELL#=' num2str(cellNum) ' ROI#=', num2str(xpr.cellIDs(cellNum)), ', angle=', angles{g}]);
        legend off
        subplot(2,4,2*g);
        gk_plot_tuning(xpr, cellNum, g, xpr.stimValues, xlabl)
        title(['CELL#=' num2str(cellNum) ' ROI#=', num2str(xpr.cellIDs(cellNum)), ', angle=', angles{g}]);
    end
    
else
    g=1;
    subplot(1,2,1);
    gk_plot_trials(xpr, cellNum, g, xpr.stimValues, false)
    subplot(1,2,2);
    gk_plot_tuning(xpr, cellNum, g, xpr.stimValues, xlabl)
    
end