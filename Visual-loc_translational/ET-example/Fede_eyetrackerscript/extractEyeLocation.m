clear all

logfile_dir = '/Data/CrossMot/Behavoiral/EyeTracker/Version_1/logfiles/';
edf_dir = '/Data/CrossMot/Behavoiral/EyeTracker/Version_1/RAW';


SubData(1).name = 'FeFa';
SubData(1).runNum = [4:11] ;

SubData(2).name = 'MaBa';
SubData(2).runNum = [1:2 4:9] ;

SubData(3).name = 'AnGu';
SubData(3).runNum = [3 4 5 6 8 9 10 11] ;

SubData(4).name = 'RoCa';
SubData(4).runNum = [1 2 3 4 6 8 9 10] ;

SubData(5).name = 'CaMa';
SubData(5).runNum = [2:9] ;

SubData(6).name = 'VJ';
SubData(6).runNum = [1 2 3 5 8 10 11 12] ;

SubData(7).name = 'StMa';
SubData(7).runNum = [2 3 4 5 6 7 8 9] ;

% Excluded because events were recorded for every event seperately inside
% the block.
% SubData(8).name = 'FrBa';
% SubData(8).runNum = [1 2 3 4 5 6 8 9] ;


for iSub = 1%:length(SubData)

    Subname = SubData(iSub).name ;    % Get the subject name
    SubRuns = SubData(iSub).runNum ;  % Get the Idx of the runs

    for iRun=1:length(SubRuns)        % For each run

        Run = SubRuns(iRun);

        % Get and load the logfile and the edf file
        logfile = fullfile(logfile_dir,[Subname,'_run_',num2str(Run),'_all.mat']);
        edf_file = fullfile(edf_dir,[Subname,num2str(Run),'.edf']);
        load(logfile,'eventNames');
        edf = Edf2Mat(edf_file);

        NewTrial = [];
        % find end of each events  (timing of non consequtive events will be larger than one)
        for iS = 2: length(edf.Samples.time)
            NewTrial(iS)= edf.Samples.time(iS)- edf.Samples.time(iS-1)>1;
        end

        eventStart_idx = [1 find(NewTrial==1)];
        eventEnd_idx = [find(NewTrial==1)-1  length(NewTrial)];

        eventEndDuration(iRun,:) = eventEnd_idx - eventStart_idx

    end


    %%
    durationUsed = min(eventEndDuration(:));
    %% Create x and y zero matrix
    x_pos = zeros(durationUsed,5,length(SubRuns));
    y_pos = zeros(durationUsed,5,length(SubRuns));

    for iRun=1:length(SubRuns)

        Run = SubRuns(iRun);

        % Get and load the logfile and the edf file
        logfile = fullfile(logfile_dir,[Subname,'_run_',num2str(Run),'_all.mat']);
        edf_file = fullfile(edf_dir,[Subname,num2str(Run),'.edf']);
        load(logfile,'eventNames')
        edf = Edf2Mat(edf_file);

        NewTrial = [];
        % find end of events  (timing of non consequtive events will be larger than one)
        for iS = 2: length(edf.Samples.time)
            NewTrial(iS)= edf.Samples.time(iS)- edf.Samples.time(iS-1)>1;
        end

        eventStart_idx = [1 find(NewTrial==1)];
        eventEnd_idx   = eventStart_idx + (durationUsed-1);

        %eventEndDuration(iRun,:) = eventEnd_idx - eventStart_idx


        %
        U_idx = find(ismember(eventNames,'A_U'));
        D_idx = find(ismember(eventNames,'A_D'));
        R_idx = find(ismember(eventNames,'A_R'));
        L_idx = find(ismember(eventNames,'A_L'));
        S_idx = find(ismember(eventNames,'A_S'));


        x_pos(:,1,iRun) = edf.Samples.posX(eventStart_idx(U_idx):eventEnd_idx(U_idx));
        x_pos(:,2,iRun) = edf.Samples.posX(eventStart_idx(D_idx):eventEnd_idx(D_idx));
        x_pos(:,3,iRun) = edf.Samples.posX(eventStart_idx(R_idx):eventEnd_idx(R_idx));
        x_pos(:,4,iRun) = edf.Samples.posX(eventStart_idx(L_idx):eventEnd_idx(L_idx));
        x_pos(:,5,iRun) = edf.Samples.posX(eventStart_idx(S_idx):eventEnd_idx(S_idx));

        y_pos(:,1,iRun) = edf.Samples.posY(eventStart_idx(U_idx):eventEnd_idx(U_idx));
        y_pos(:,2,iRun) = edf.Samples.posY(eventStart_idx(D_idx):eventEnd_idx(D_idx));
        y_pos(:,3,iRun) = edf.Samples.posY(eventStart_idx(R_idx):eventEnd_idx(R_idx));
        y_pos(:,4,iRun) = edf.Samples.posY(eventStart_idx(L_idx):eventEnd_idx(L_idx));
        y_pos(:,5,iRun) = edf.Samples.posY(eventStart_idx(S_idx):eventEnd_idx(S_idx));


        %plot(x_pos(:,:,1),y_pos(:,:,1),'o','color',[0 0 0]);


    end

    Conditions = {'U','D','R','L','S'};

   % save(fullfile(pwd,'processed',[Subname,'.mat']))

end


for EACH_EVENT
vector_tmp= edf.Samples.posX(eventStart_idx(EACH_EVENT):eventEnd_idx(EACH_EVENT))
is_BAD(EACH_EVENT,1) = vector_tmp>Threshold
end