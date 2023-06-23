function gk_DES_func(func,coh,wk,ms,ex,force,whichSegments)
% USAGE: gk_DES_func(func,coh,wk,ms,ex,[force],[whichSegments])
%
% INPUT:
%   func: function to perform, can be one of the following:
%         'done_info' : information on what has been not done yet
%         'cdProc'    : goes to the processed data folder and waits
%                       (keyboard - you can use dbcont to continue)
%         'cdRaw'     : goes to the raw data folder and waits
%                       (keyboard - you can use dbcont to continue)
%         'h5'        : processes the h5 to get the stimulus times
%         'frT'       : gets the frame times, h5 has to be already done
%         'stimA'     : extracts the stimA
%         'sync'      : checks and adjusts the timing 'frT has to be done
%
%   coh : the mouse cohort - 'coh1' or 'coh2' or [] for all
%   wk  : the timepoint - 'w11' or 'w22' or [] for all
%   ms  : the mouse id e.g. M19
%   ex  : the experiment id e.g. 'contrast', 'OR', 'DR', 'RF', etc.
%   force: forces the function to run even if it was done before
%   whichSegments: for stimA one can define which segments to get
%
% Author: Georgios Keliris, March 2023

if ~exist('force')
    force=false;
end
if ~exist('whichSegments')
    whichSegments='all';
end
load('D:\all_exp_description.mat');

if ~exist('coh') || isempty(coh)
    coh=fieldnames(DES);
else
    coh={coh};
end
if ~exist('wk') || isempty(wk)
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
if ~exist('ex') || isempty(ex)
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
                        case 'stimA'
                            if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==0 || force
                                DES = stimA_func(DES,coh,ci,wk,wi,ms,mi,ex,ei,whichSegments);
                                save('D:\all_exp_description.mat','DES')
                            end
                        case 'stim'
                            stim_func(DES,coh,ci,wk,wi,ms,mi,ex,ei)
                        case 'sync'
                            if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).syncdone==0 || force
                            if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==1 && ...
                               DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==1
                                DES = sync_func(DES,coh,ci,wk,wi,ms,mi,ex,ei,force);
                                save('D:\all_exp_description.mat','DES')
                            else
                                fprintf('%s, %s, %s, %s: ERROR: Both h5 and stimA need to be done\n',coh{ci},wk{wi},ms{mi},ex{ei})
                            end
                            end
                        case 'addStimulus'
                            addStimulus_func(DES,coh,ci,wk,wi,ms,mi,ex,ei,force)
                        otherwise
                            disp('Unknown method.')
                    end
                catch ME
                    %% 
                    display(getReport(ME))
                    fprintf('%s, %s, %s, %s: CRASH\n',coh{ci},wk{wi},ms{mi},ex{ei})
                    keyboard
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

if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==0
    fprintf('%s, %s, %s, %s: h5 not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==2
    fprintf('%s, %s, %s, %s: h5 was skipped\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==3
    fprintf('%s, %s, %s, %s: h5 not found\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).h5done==4
    fprintf('%s, %s, %s, %s: h5 not readable\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone==0
    fprintf('%s, %s, %s, %s: frT not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).frTdone==-1
    fprintf('%s, %s, %s, %s: frT error\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==0
    fprintf('%s, %s, %s, %s: stimA not done\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone==-1
    fprintf('%s, %s, %s, %s: stimA error\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
if DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).syncdone==0
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
%%%%%%%%%%%%%%%%%%%s%temporary added for fixing the filename errors:
    if ~isfile([DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath '\' DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff])

%       tempindex=strfind(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff,'_');
%       DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff=insertAfter(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff,tempindex(2),'_');

%          tempindex=strfind(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff,'1_');
%          DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff(tempindex)='2';
%for w11_M145_SF_20220103: 
%        tempindex=strfind(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff,'__');
%        DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff(tempindex)='';
    end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%---------------------------------------------------------------------------
function DES = stimA_func(DES,coh,ci,wk,wi,ms,mi,ex,ei,whichSegments)

fprintf("Processing: %s, %s, %s, %s \n",coh{ci},wk{wi},ms{mi},ex{ei});
try
    stimA=gk_get_stimArtifact(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,...
        DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).firstTiff,whichSegments);
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stimA'),'stimA');
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone=1; % means it was done
catch
    fprintf('Warning: something went wrong, moving to the next one\n')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).stimAdone=-1; % means there was an error
    return
end
return
%-----------------------------------------------------------------------------------
function stim_func(DES,coh,ci,wk,wi,ms,mi,ex,ei)

fprintf("Processing: %s, %s, %s, %s \n",coh{ci},wk{wi},ms{mi},ex{ei});

try
    load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim_t.mat'))
    load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'frame_t.mat'))
    stim.Times = gk_getStimFrameTimes(stim_t,frame_t);
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim'),'stim');
catch
    fprintf('Warning: something went wrong, moving to the next one\n')
    return
end
%-----------------------------------------------------------------------------------
function DES = sync_func(DES,coh,ci,wk,wi,ms,mi,ex,ei,force)


d=dir(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,'*.h5'));
h5 = gk_readH5(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath,d.name));

load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'));
load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stimA.mat'));
mydTpath=fileparts(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath);
if force==0
try
    load(fullfile(mydTpath,'mydT.mat'));
    expIndex = find(strcmp(mydT.folder,DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath));
    if isempty(expIndex)
        fprintf('%s\n',DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).rawPath)
        mydT.folder
        expIndex = input("Please enter expIndex manually: expIndex = ");
    end
    dT=mydT.dT(expIndex);
    stim.Times = gk_check_stimTiming(stim.Times, stimA, h5, dT);
catch
    stim.Times = gk_check_stimTiming(stim.Times, stimA, h5);
end
elseif force
    stim.Times = gk_check_stimTiming(stim.Times, stimA, h5);
end

answer = input("Save stim.mat y/n [n]? ","s");
if isempty(answer)
    answer='n';
end
if strcmp(answer,'y')
    DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).syncdone=1;
    save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'),'stim');
end
return
%-----------------------------------------------------------------------------------
function addStimulus_func(DES,coh,ci,wk,wi,ms,mi,ex,ei,force)

if isfile(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'))
    load(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'));
    if ~isfield(stim,'Values') || force
        if contains(upper(ex{ei}),'CONTRAST')
            load('D:\2 visual stimulus files\contrast2.mat')
            stim.expType='contrast';
            stim.IDs=[Stims; Stims;];      
        elseif contains(upper(ex{ei}),'DR')
            load('D:\2 visual stimulus files\direction.mat')
            stim.expType='DR';
            stim.IDs=Stims;
        elseif contains(upper(ex{ei}),'OR')
            load('D:\2 visual stimulus files\orientation.mat')
            stim.expType='OR';
            stim.IDs=Stims;
        elseif contains(upper(ex{ei}),'RF')
            load('D:\2 visual stimulus files\RF.mat')
            stim.expType='RF';
            [uS, ~, pos2] = unique(cellcenter,'rows');
            stim.uniquePos=uS;
            stim.IDs=CellIndex';
            StimTyps=(1:60)';
            stim.posIDs=pos2;
        elseif contains(upper(ex{ei}),'SF')
            load('D:\2 visual stimulus files\SF.mat')
            stim.expType='SF';
            stim.IDs=[Stims(1:100); Stims(1:100); Stims(1:100); Stims(1:100)];
        elseif contains(upper(ex{ei}),'TF')
            load('D:\2 visual stimulus files\TF.mat')
            stim.expType='TF';
            stim.IDs=[Stims(1:100); Stims(1:100); Stims(1:100); Stims(1:100)];
        elseif contains(upper(ex{ei}),'OO')
            stim.expType='OO';
            StimTyps=[1 0]';
            stim.IDs=[repmat([1 2],1,20)]';
        else
            % treat here potential future exp types
        end
        stim.Values=StimTyps;
        Ntrials = size(stim.Times.frame_onsets,2);
        Ntrials_equal = Ntrials - rem(Ntrials,numel(stim.Values));
        if Ntrials>numel(stim.IDs)
            stim.IDs=[stim.IDs; stim.IDs];
        end
        stim.IDs=stim.IDs(1:Ntrials_equal);
        save(fullfile(DES.(coh{ci}).(wk{wi}).(ms{mi}).(ex{ei}).procPath,'stim.mat'),'stim');
    end
else
    fprintf('%s, %s, %s, %s: stim.mat is not yet created\n',coh{ci},wk{wi},ms{mi},ex{ei})
end
return
