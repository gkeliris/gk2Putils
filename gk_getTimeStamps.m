function ts = gk_getTimeStamps(tif_file)

header = imfinfo(tif_file);
hdr={header(:).ImageDescription};
pat='_sec = (?<t>\d+\.\d+\s)';
res=regexp(hdr,pat,'names');
a=cell2mat(res);
ts=str2num([a.t]);