function [cellNum, prfGrp] = getCellNum(xpr, tunedCellID)

cellNum = xpr.onTunedIDs_allGrp(tunedCellID);
prfGrp = xpr.grpOrder(tunedCellID,1);
