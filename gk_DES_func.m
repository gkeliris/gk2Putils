function gk_DES_func(func,coh,wk,ms,ex,force)
if ~exist('force')
    force=false;
end
load('D:\all_exp_description.mat');

if ~exist('coh') | isempty(coh)
    coh=fieldnames(DES);
else
    coh={coh};
end
if ~exist('wk') | isempty(wk)
    wk=fieldnames(DES.coh1);
else
    wk={wk};
end
if ~exist('ms') | isempty(ms)
    msset=1;
else
    msset=0;
    ms={ms};
end
if ~exist('ex') | isempty(ex)
    exset=1;
else
    exset=0;
    ex={ex};
end

% loop over cohorts, week, mice and perform "func"
for ci=1:numel(coh)
    for wi=1:numel(wk)
        if msset
            ms=fieldnames(DES.(coh{ci}).(wk{wi}));
        end
        for mi=1:numel(ms)
            if exset
                ex=fieldnames(DES.(coh{ci}).(wk{wi}).(ms{mi}));
            end
            for ei=1:numel(ex)
                if ~strcmp('Spon',ex{ei}) && ~strcmp('Spon2',ex{ei}) && ~strcmp('Spon_1106',ex{ei})
                try
                    switch func
                        case 'done_info'
                            info_func(DES,coh,ci,wk,wi,ms,mi,ex,ei);
                        case 'cdProc'
                            cd(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath);
                            keyboard;
                        case 'cdRaw'
                            cd(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath);
                            keyboard;
                        case 'h5'
                            if ~DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done || force
                                DES = h5_func(DES,coh,ci,wk,wi,ms,mi,ex,ei);
                                save('D:\all_exp_description.mat','DES')
                            end
                        case 'frT'
                            if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone==0 || force
                                DES = frT_func(DES,coh,ci,wk,wi,ms,mi,ex,ei);
                                save('D:\all_exp_description.mat','DES')
                            end
                        case 'sync'
                            if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).syncdone==0 || force
                            if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==1 && ...
                               DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==1
                                DES = sync_func(DES,coh,ci,wk,wi,ms,mi,ex,ei);
                                save('D:\all_exp_description.mat','DES')
                            else
                                fprintf('%s, %s, %s, %s: ERROR: Both h5 and stimA need to be done\n',coh{ci},wk{wi},ms{mi},ex{ei})
                            end
                            end
                        otherwise
                            disp('Unknown method.')
                    end
                catch
                    %% 
                    keyboard
                    
                    fprintf('%s, %s, %s, %s: CRASH\n',coh{ci},wk{wi},ms{mi},ex{ei})
                end
                end
            end

        end
    end
end
return


%% subfunctions
%---------------------------------------------------------------------------
function info_func(DES,coh,ci,wk,wi,ms,mi,ex,ei)

if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==0;
    fprintf('%s, %s, %s, %s: h5 not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==2;
    fprintf('%s, %s, %s, %s: h5 was skipped\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==3;
    fprintf('%s, %s, %s, %s: h5 not found\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==4;
    fprintf('%s, %s, %s, %s: h5 not readable\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone==0;
    fprintf('%s, %s, %s, %s: frT not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone==-1;
    fprintf('%s, %s, %s, %s: frT error\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==0;
    fprintf('%s, %s, %s, %s: stimA not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==-1;
    fprintf('%s, %s, %s, %s: stimA error\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).syncdone==0;
    fprintf('%s, %s, %s, %s: sync not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
return
%---------------------------------------------------------------------------
function DES = h5_func(DES,coh,ci,wk,wi,ms,mi,ex,ei)

fprintf("Processing: %s, %s, %s, %s \n",coh{ci},wk{wi},ms{mi},ex{ei});
% try to find the h5 file
d=dir(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,'*.h5'));
if isempty(d)
    d=dir(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'*.h5'));
    if isempty(d)
        fprintf('Warning: Could not find H5 file, moving to the next one\n');
        DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done=3; % means not found
        return
    end
end
if numel(d)>1
    fprintf('Found 2 or more H5 files, please check\n');
    keyboard
end
try
    h5 = gk_readH5(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,d.name));
catch
    fprintf('Warning: Could not read the H5 file, moving to the next one\n')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done=4; % means it could not read the file
    return
end

answer='n';
while strcmp(answer,'n')
    stim_t = gk_getStimTimes(h5);
    answer = input('Continue to the next (y) - (n) to try again - (s) to skip [y/n/s]? ','s');
end
if strcmp(answer,'y')
    if ~isfolder(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath)
        mkdir(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath);
    end
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim_t'),'stim_t');
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done=1;
end
if strcmp(answer,'s')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done=2; % means skipped
end
return
%---------------------------------------------------------------------------
function DES = frT_func(DES,coh,ci,wk,wi,ms,mi,ex,ei)

fprintf("Processing: %s, %s, %s, %s \n",coh{ci},wk{wi},ms{mi},ex{ei});
try
    frame_t = gk_getTimeStamps2P(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,...
        DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff);
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'frame_t'),'frame_t');
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone=1; % means it was done
    load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim_t.mat'))
    stim.Times = gk_getStimFrameTimes(stim_t,frame_t);
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim'),'stim');
catch
    fprintf('Warning: something went wrong, moving to the next one\n')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone=-1; % means there was an error
    return
end
try
    stimA=gk_get_stimArtifact(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,...
        DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff,'all');
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stimA'),'stimA');
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone=1; % means it was done
catch
    fprintf('Warning: something went wrong, moving to the next one\n')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone=-1; % means there was an error
    return
end
return
%-----------------------------------------------------------------------------------
function DES = sync_func(DES,coh,ci,wk,wi,ms,mi,ex,ei);


d=dir(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,'*.h5'));
h5 = gk_readH5(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,d.name));

load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'));
load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stimA.mat'));

stim.Times = gk_check_stimTiming(stim.Times, stimA, h5);

answer = input("Save stim.mat y/n [n]? ","s");
if isempty(answer)
    answer='n';
end
if strcmp(answer,'y')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).syncdone=1;
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'),'stim');
end
return