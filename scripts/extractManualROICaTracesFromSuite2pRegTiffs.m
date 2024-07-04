clearvars

% requires natsortfiles.m: <https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort>

%% select suite2p registered TIFF and manually selected ROIs
prompt = {'Suite2p registered output TIFF:','roigui .mat file:'};
dlgtitle = 'Path to files';
dims = [1 35];
definput = {'.tif','.mat'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

file_parts = split(answer{1}, '/');
mouse_name = file_parts{contains(file_parts, 'JL')}; % outputs multiple values but we only care about the first one in the path
timepoint_name = file_parts{ contains(file_parts, digitsPattern + ' ')};
[reg_tiff_folder, ~, ~] = fileparts(answer{1});

% load manual ROIs and count
load(answer{2}, 'ROI_list');
num_ROIs = length(ROI_list);
% ROI_pix_list = {ROI_list.pixel_list};
% max_pix = max(cellfun(@length, ROI_pix_list));
% 
% ROI_pix = cell2mat(cellfun(@(x) [x; nan(max_pix-numel(x),1)], ROI_pix_list, 'UniformOutput', false))';

% load suite2p-segmented ROIs with total number of frames
F_s2p = load(fullfile(fileparts(reg_tiff_folder), 'Fall.mat'), 'F');

tic
% find all motion corrected tiff segments and import in ascending order
file_list = dir(fullfile(reg_tiff_folder, '*chan*.tif'));
sorted_files = natsortfiles(file_list);
num_files = length(sorted_files);

% get image dimensions from first tiff segment
curr_tiff = fullfile(sorted_files(1).folder, sorted_files(1).name);
fprintf("\tImporting header info for all frames...\n");
img_info = imfinfo(curr_tiff);
yx = [img_info(1).Height, img_info(1).Width];
toc

% frames per tiff segment
seg_frames = numel(img_info);

% loop over all tiff segments to extract average F value of pixels from each manually selected ROI
F_segment = nan(num_ROIs, seg_frames, num_files);
parfor f = 1:num_files                         % loop over all tiff segments
    F_block = nan(num_ROIs, seg_frames);    % average F value of each ROI in each frame of current tiff segment
    curr_tiff = fullfile(sorted_files(f).folder, sorted_files(f).name);   % path to current tiff segment
    img_info = imfinfo(curr_tiff);
    num_frames = numel(img_info);
    fprintf('%s || %s %s || File %i of %i\n', datestr(now,'yyyy-mm-dd HH:MM:SS'), mouse_name, timepoint_name, f, num_files);
    for i_frame = 1:num_frames              % loop over all frames in current tiff segment
        img = double(imread(curr_tiff,'Index',i_frame,'Info',img_info));  % load current frame

        for r = 1:num_ROIs                  % calculate mean F value of all pixels for each ROI in current frame
            F_block(r, i_frame) = mean(img(ROI_list(r).pixel_list));
        end
    end
    F_segment(:,:,f) = F_block;
end

% rearrange 3D array into 2D array in ROIs x frames shape, to match F from suite2p output
F = reshape(F_segment, size(F_segment,1), [] ,1);

% consistency checks to confirm # of total frames extracted from manual ROIs matches # of suite2p frames
if size(F_s2p.F,2) == size(F,2) - nnz(sum(isnan(F),1))
    F = F(:, 1:size(F_s2p.F,2));
else
    error("Number of frames in from suite2p data does not match frames from manual ROI segmentation.")
end

save_loc = fullfile(fileparts(reg_tiff_folder), 'F_manual.mat');
save(save_loc, 'F');
fprintf('%s || %s %s || Saved averaged F from manually segmented ROIs to "%s"\n', datestr(now,'yyyy-mm-dd HH:MM:SS'), mouse_name, timepoint_name, save_loc);

