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
    catch
        data=cat(3,data,read_file(fullfile(d(i).folder,d(i).name)));
    end
    toc
end
%fprintf('Converting to int16\n')
data = reshape(typecast(data(:),'int16'),[size(data)]);
toc
