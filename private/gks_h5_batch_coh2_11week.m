 if isfile(fullfile('E:\Mecp2_cohort2_11wks raw and processed','exp_description.mat'))
    load(fullfile('E:\Mecp2_cohort2_11wks raw and processed','exp_description'));
    fprintf('Loaded exp_description from disk\n');
    diary(fullfile('E:\Mecp2_cohort2_11wks raw and processed',[datestr(now,'yyyy-mm-dd_HHMMSS'),'_log.txt']))
else
     gks_mecp2_description_cohort2_11weeks;
end

c=fieldnames(descr);
for ci=1:numel(c)
    m=fieldnames(descr.(c{ci}));
   for mi=1:numel(m)
          e=fieldnames(descr.(c{ci}).(m{mi}));
        for ei=1:numel(e)
          if ~isfile(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim.mat')) && ...
                    ~isfile(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim_t.mat')) && ...
                    (~isfield(descr.(c{ci}).(m{mi}).(e{ei}),'h5done') || ...
                    ~descr.(c{ci}).(m{mi}).(e{ei}).h5done)
                fprintf("Processing: %s, %s, %s \n",c{ci},m{mi},e{ei});
                % try to find the h5 file
                d=dir(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).rawPath,'*.h5'));
                if isempty(d)                    
                    d=dir(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'*.h5'));
                    if isempty(d)
                        fprintf('Warning: Could not find H5 file, moving to the next one\n');
                        descr.(c{ci}).(m{mi}).(e{ei}).h5done=3; % means not found
                        break
                    end
                end
                if numel(d)>1
                    fprintf('Found 2 or more H5 files, please check\n');
                    keyboard                                                                                                                                                                    
                    
                end
                try
                    h5 = gk_readH5(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).rawPath,d.name));
                catch
                    fprintf('Warning: Could not read the H5 file, moving to the next one\n')
                    descr.(c{ci}).(m{mi}).(e{ei}).h5done=4; % means it could not read the file
                    break; 
                end
                answer='n';
                while strcmp(answer,'n')
                    stim_t = gk_getStimTimes(h5);
                    answer = input('Continue to the next (y) - (n) to try again - (s) to skip - q to save and quit [y/n/s/q]? ','s');
                end
                if strcmp(answer,'y')
                    if ~isfolder(descr.(c{ci}).(m{mi}).(e{ei}).procPath)
                        mkdir(descr.(c{ci}).(m{mi}).(e{ei}).procPath);
                    end
                    save(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim_t'),'stim_t');
                    descr.(c{ci}).(m{mi}).(e{ei}).h5done=1;
                end
                if strcmp(answer,'q')
                    save(fullfile('E:\Mecp2_cohort2_11wks raw and processed','exp_description'),'descr');
                    diary off
                    return
                end
                if strcmp(answer,'s')
                    descr.(c{ci}).(m{mi}).(e{ei}).h5done=2; % means skipped
                end
            end
        end
    end
end


diary off