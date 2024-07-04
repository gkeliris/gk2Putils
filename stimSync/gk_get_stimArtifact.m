function stimA = gk_get_stimArtifact(fpath, firstTiff, whichSegments)
% USAGE: stimA = gk_get_stimArtifact(fpath, firstTiff, whichSegments)
%

if nargin<1
    [firstTiff, fpath] = uigetfile('*.tif','Select the first tiff segment');
end
if nargin<2
    firstTiff=ls(fullfile(fpath,'*00001.tif'));
end
if nargin<3
    whichSegments='all';
end
[~, fname]=fileparts(firstTiff);
tiffSegments = dir(fullfile(fpath, [fname(1:end-4) '*.tif']));
if isstr(whichSegments)
  whichSegments=1:length(tiffSegments);  
end

tStart = tic;
fprintf('Beginning import of tall TIFF stacks.\n');
% assume TIFF labeling is "TITLE_EXPERIMENT_SEGMENT.tif"
nameParts = split(tiffSegments(1).name, '_');

% loop over all TIFFs
stimA.v=[]; stimA.t=[];
for i=[whichSegments] %1:length(tiffSegments)
   fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(tiffSegments));
 %     fprintf("\tProcessing TIFF segment %i of %i...\n", i, length(whichSegments));
    try 
        dat=parallelReadTiff(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
        %obj=scanimage.util.ScanImageTiffReader(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
        %dat=data(obj);
    catch
        info=imfinfo(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
        dat=zeros(info(1).Height,info(1).Width,numel(info));
        for fi=1:numel(info)
            dat(:,:,fi)=imread(fullfile(tiffSegments(i).folder, tiffSegments(i).name), fi);
        end
    end
    [ts, zL] = gk_getTimeStamps(fullfile(tiffSegments(i).folder, tiffSegments(i).name));
    dat=reshape(dat,size(dat,1)*size(dat,2),size(dat,3));
    if i==whichSegments(1)
        nCh=numel(ts)/numel(unique(ts));
        nZ=numel(zL);
    end
    
    for c=1:nCh
        MI=mean(dat(:,c:nCh*nZ:end),2);
        QQ(c)=quantile(MI,0.05);
        lowVal{c}=find(MI<QQ(c));
        if c==1
            stimA.v=[stimA.v; mean(dat(lowVal{c},c:nCh*nZ:end))'];
            stimA.t=[stimA.t; ts(c:nCh*nZ:end)];
        else
            if ~isfield(stimA,['v',num2str(c)])
                stimA.(['v',num2str(c)])=[];
            end
            stimA.(['v',num2str(c)])=...
                [stimA.(['v',num2str(c)]); mean(dat(lowVal{c},c:nCh*nZ:end))'];
        end
    end
end

fprintf("Full completed in %.2f s.\n", toc(tStart));