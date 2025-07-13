function [sig, sigNeu] = loadFissa(ds, sigName, plane)
% USAGE: sig = loadSig(ds, sigName, plane)
%
% INPUT:
%   ds          - table returned by gk_datasetQuery
%   sigName     - 'result','raw', 'deltaf_result', 'deltaf_raw',...
%   plane       - 'plane0', 'plane1',..., or  0, 1
%
% Author: Georgios A. Keliris

if nargin<3
    plane='combined';
end

if isnumeric(plane)
    plane=['plane', num2str(plane)];
end

sesPath = setSesPath(ds);
if ~isfile(fullfile(sesPath,'suite2p_orig',plane,'FISSA','separated.mat'))
    error('FISSA mat FILE NOT FOUND! Make sure dataset was preprocessed and try again.\n')
    return
end
load(fullfile(sesPath,'suite2p_orig',plane,'FISSA','separated.mat'),sigName);
ncells=eval(['size(' sigName ',1)']);
for c=1:ncells
    tmp=eval(['[' (sigName) '{c,:}]']);
    if c==1
        sig=zeros(ncells,size(tmp,2));
        sigNeu=sig;
    end
    sig(c,:)=tmp(1,:);
    sigNeu(c,:)=mean(tmp(2:end,:),1);
end
%     
% sig=reshape(tmp(1,:),[],ncells)';
% sigNeu=reshape(mean(tmp(2:end,:),1),[],ncells)';
