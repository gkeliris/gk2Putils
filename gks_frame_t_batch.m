if isfile(fullfile('D:\1.2 MeCP2cohort1_11weeks_processed','exp_description.mat'))
    load(fullfile('D:\1.2 MeCP2cohort1_11weeks_processed','exp_description'));
    fprintf('Loaded exp_description from disk\n');
    diary(fullfile('D:\1.2 MeCP2cohort1_11weeks_processed',[datestr(now,'yyyy-mm-dd_HHMMSS'),'_log.txt']))
else
    gks_mecp2_description;
end

c=fieldnames(descr);
for ci=1:numel(c)
    m=fieldnames(descr.(c{ci}));
    for mi=1:numel(m)
        e=fieldnames(descr.(c{ci}).(m{mi}));
        for ei=1:numel(e)
            
            if ~isfile(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim.mat')) && ...
                    isfile(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim_t.mat')) && ...
                    ~isfile(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'frame_t.mat')) && ...
                    (~isfield(descr.(c{ci}).(m{mi}).(e{ei}),'frTdone') || ...
                    ~descr.(c{ci}).(m{mi}).(e{ei}).frTdone)
                fprintf("Processing: %s, %s, %s \n",c{ci},m{mi},e{ei});
                % 
                try
                    frame_t = gk_getTimeStamps2P(descr.(c{ci}).(m{mi}).(e{ei}).rawPath,...
                        descr.(c{ci}).(m{mi}).(e{ei}).firstTiff);
                    save(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'frame_t'),'frame_t');
                    descr.(c{ci}).(m{mi}).(e{ei}).frTdone=1; % means it was done
                    load(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim_t.mat'))
                    stim.Times = gk_getStimFrameTimes(stim_t,frame_t);
                    save(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stim'),'stim');
                    stimA=gk_get_stimArtifact(descr.(c{ci}).(m{mi}).(e{ei}).rawPath,...
                        descr.(c{ci}).(m{mi}).(e{ei}).firstTiff,'all');
                    save(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).procPath,'stimA'),'stimA');
                catch
                    fprintf('Warning: something went wrong, moving to the next one\n')
                    descr.(c{ci}).(m{mi}).(e{ei}).frTdone=-1; % means there was an error
                    break; 
                end
            end
        end
    end
end

save(fullfile('D:\1.2 MeCP2cohort1_11weeks_processed','exp_description'),'descr');
diary off