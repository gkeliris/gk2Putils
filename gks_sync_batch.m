 if isfile(fullfile('E:\Mecp2_cohort2_11wks raw and processed','exp_description.mat'))
    load(fullfile('E:\Mecp2_cohort2_11wks raw and processed','exp_description'));
    fprintf('Loaded exp_description from disk\n');
    diary(fullfile('E:\Mecp2_cohort2_11wks raw and processed',[datestr(now,'yyyy-mm-dd_HHMMSS'),'_log.txt']))
 else
        keyboard
 end

c=fieldnames(descr);
for ci=1:numel(c)
    m=fieldnames(descr.(c{ci}));
    for mi=1:numel(m)
        e=fieldnames(descr.(c{ci}).(m{mi}));
        for ei=1:numel(e)
            cd(descr.(c{ci}).(m{mi}).(e{ei}).procPath);
            clear stim stimA
            d=dir(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).rawPath,'*.h5'));
            h5 = gk_readH5(fullfile(descr.(c{ci}).(m{mi}).(e{ei}).rawPath,d.name));
            
            load stim.mat
            load stimA.mat
            
            stim.Times = gk_check_stimTiming(stim.Times, stimA, h5);
            
            answer = input("Save stim.mat y/n [n]? ","s");
            if isempty(answer)
                answer='n';
            end
            if strcmp(answer,'y')
                save('stim','stim');
            end
        end
    end
end


diary off