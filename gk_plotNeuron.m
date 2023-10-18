function gk_plotNeuron(coh,wk,ms,ex,roiNum)

tc = gk_getCellTimecourse(coh,wk,ms,ex,roiNum);

plot(tc.t,tc.v(1:numel(tc.t)),'k');