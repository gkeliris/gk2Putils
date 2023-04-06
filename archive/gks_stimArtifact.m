
stim=[];
for i=1:93
tallTiffStack = [];%imread(fullfile(tiffSegments(i).folder, tiffSegments(i).name), 1);   % first frame
try
for j = 2:8:size(header, 1)
    tiffFrame = imread(fullfile(tiffSegments(i).folder, tiffSegments(i).name), j);
    tallTiffStack = cat(3, tallTiffStack, tiffFrame);
end
end
stim=[stim; squeeze(mean(tallTiffStack,[1,2]))];
end
plot(stim)