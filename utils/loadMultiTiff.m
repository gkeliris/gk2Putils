function data = loadMultiTiff(pth,pattern)
% USAGE: data = loadMultiTiff(pth,pattern)
%
% example: pth=pwd; data = loadMultiTiff(pth,'file*.tif');


tic
d=dir(fullfile(pth,pattern));
data=[];
for i=1:numel(d)
    fprintf('Loading file: %s\n',d(i).name)
    try
        data=ct(3,data,parallelReadTiff(fullfile(d(i).folder,d(i).name)));
        tc=false;
    catch
        tc=true;
        data=cat(3,data,read_file(fullfile(d(i).folder,d(i).name)));
    end
    toc
end
%fprintf('Converting to int16\n')
if tc
    data = reshape(typecast(data(:),'int16'),[size(data)]);
end
toc
