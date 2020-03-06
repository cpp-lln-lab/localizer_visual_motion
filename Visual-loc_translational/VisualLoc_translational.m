%% Visual hMT localizer using translational motion in four directions
%  (up- down- left and right-ward)

% by Mohamed Rezk 2018
% adapted by MarcoB 2020

%%

% Clear all the previous stuff
% clc;
if ~ismac
    clear;
    close all;
    clear Screen;
    PsychPortAudio('Close');
end

% make sure we got access to all the required functions and inputs
addpath(fullfile(pwd, 'subfun'))

% set and load all the parameters to run the experiment
[subjectName, runNumber, sessionNumber] = UserInputs;
[ExpParameters, Cfg] = SetParameters;

%%  Experiment

% Safety loop: close the screen if code crashes
try
    %% Init the experiment
    [Cfg] = InitPTB(Cfg);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % Different duratons for different number of repetitions (may add a few TRs to this number just for safety)
    % Cfg.numRepetitions=7, Duration: 345.77 secs (5.76 mins), collect 139 + 4 Triggers = 143 TRs at least per run
    % Cfg.numRepetitions=6, Duration: 297.86 secs (4.96 mins), collect 120 + 4 Triggers = 124 TRs at least per run
    % Cfg.numRepetitions=5, Duration: 249.91 secs (4.17 mins), collect 100 + 4 Triggers = 104 TRs at least per run
    % Cfg.numRepetitions=4, Duration: 201.91 secs (3.37 mins), collect 81 + 4 Triggers  = 85  TRs at least per run
    
    
    
    
    
    
    
    

    
    %% Fixation Cross
    if ExpParameters.Task1
        xCoords = [-ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix 0 0] + ExpParameters.xDisplacementFixCross;
        yCoords = [0 0 -ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix] + ExpParameters.yDisplacementFixCross;
        Cfg.allCoords = [xCoords; yCoords];
    end
    
    % monitor distance
    Cfg.mon_horizontal_cm  	= Cfg.monitor_width;                         % Width of the monitor in cm
    Cfg.view_dist_cm 		= Cfg.screen_distance;                       % Distance from viewing screen in cm
    Cfg.apD = Cfg.diameter_aperture;                                     % diameter/length of side of aperture in Visual angles
    
    
    % Everything is initially in coordinates of visual degrees, convert to pixels
    % (pix/screen) * (screen/rad) * rad/deg
    V = 2* (180 * (atan(Cfg.mon_horizontal_cm/(2*Cfg.view_dist_cm)) / pi));
    Cfg.ppd = Cfg.winRect(3) / V ;
    
    Cfg.d_ppd = floor(Cfg.apD * Cfg.ppd);                            % Covert the aperture diameter to pixels
    ExpParameters.dotSize = floor (Cfg.ppd * ExpParameters.dotSize);                          % Covert the dot Size to pixels
    
   
    % % % TO ME NOT NECESSARY
    directions=[];
    speeds=[];
    fixationTargets=[];
    
    [directions, speeds, fixationTargets, names] = experimentalDesign(Cfg);
    
    numBlocks = size(directions,1);
    
    %%%%%%%%%%%%%%%%%%%%%%
    % experiment
    %%%%%%%%%%%%%%%%%%%%%%
    %Instructions
    DrawFormattedText(Cfg.win,'1-Detect the RED fixation cross\n \n\n',...
        'center', 'center', Cfg.textColor);
    Screen('Flip', Cfg.win);
    
    KbWait();
    KeyIsDown=1;
    while KeyIsDown>0
        [KeyIsDown, ~, ~]=KbCheck(-1);
    end
    
    %% Empty vectors and matrices for speed
    blockNames     = cell(numBlocks,1);
    blockOnsets    = zeros(numBlocks,1);
    blockEnds      = zeros(numBlocks,1);
    blockDurations = zeros(numBlocks,1);
    
    eventOnsets    = zeros(numBlocks,ExpParameters.numEventsPerBlock);
    eventEnds      = zeros(numBlocks,ExpParameters.numEventsPerBlock);
    eventDurations = zeros(numBlocks,ExpParameters.numEventsPerBlock);
    
    allResponses = [] ;
    %% Wait for Trigger from Scanner
    % open Serial Port "SerPor" - COM1 (BAUD RATE: 11520)
    
    if strcmp(Cfg.Device,'PC')
        DrawFormattedText(Cfg.win,'Waiting For Trigger',...
            'center', 'center', Cfg.textColor);
        Screen('Flip', Cfg.win);
        
        %%
        triggerCounter=0;
        %fprintf('Waiting for trigger \n');
        while triggerCounter < Cfg.numTriggers
            [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
            if strcmp(KbName(keyCode),Cfg.triggerKey)
                triggerCounter = triggerCounter+1 ;
                fprintf('Trigger %s \n', num2str(triggerCounter));
                DrawFormattedText(Cfg.win,['Trigger ',num2str(triggerCounter)],'center', 'center', Cfg.textColor);
                Screen('Flip', Cfg.win);
                
                while keyIsDown
                    [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
                end
            end
        end
        
    end
    
    Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
    Screen('Flip',Cfg.win);
    
    %% txt logfiles
    if ~exist('logfiles','dir')
        mkdir('logfiles')
    end
    
    BlockTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_Blocks.txt']),'w');
    fprintf(BlockTxtLogFile,'%12s  %12s %12s %12s %12s \n',...
        'BlockNumber','Condition','Onset','End','Duration');
    
    EventTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_Events.txt']),'w');
    fprintf(EventTxtLogFile,'%12s %12s %12s %18s %12s %12s %12s %12s \n',...
        'BlockNumber','EventNumber','Direction', 'IsFixationTarget','Speed','Onset','End','Duration');
    
    ResponsesTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_Responses.txt']),'w');
    fprintf(ResponsesTxtLogFile,'%12s \n','Responses');
    
    %% Experiment Start
    Cfg.Experiment_start = GetSecs;
    
    WaitSecs(ExpParameters.onsetDelay);
    
    %% For Each Block
    for iBlock = 1:numBlocks
        
        fprintf('Running Block %.0f \n',iBlock)
        
        blockOnsets(iBlock,1)= GetSecs-Cfg.Experiment_start;
        
        % For each event in the block
        for iEventsPerBlock = 1:ExpParameters.numEventsPerBlock
            
            iEventDirection = directions(iBlock,iEventsPerBlock);       % Direction of that event
            iEventSpeed = speeds(iBlock,iEventsPerBlock);               % Speed of that event
            iEventDuration = ExpParameters.eventDuration ;                        % Duration of normal events
            iEventIsFixationTarget = fixationTargets(iBlock,iEventsPerBlock);
            
            % Event Onset
            eventOnsets(iBlock,iEventsPerBlock) = GetSecs-Cfg.Experiment_start;
            
            % play the dots
            responseTimeWithinEvent = DoDotMo( Cfg, iEventDirection, iEventSpeed, iEventDuration, iEventIsFixationTarget);
            
            %% logfile for responses
            if ~isempty(responseTimeWithinEvent)
                fprintf(ResponsesTxtLogFile,'%8.6f \n',responseTimeWithinEvent);
            end
            
            %% Event End and Duration
            eventEnds(iBlock,iEventsPerBlock) = GetSecs-Cfg.Experiment_start;
            eventDurations(iBlock,iEventsPerBlock) = eventEnds(iBlock,iEventsPerBlock) - eventOnsets(iBlock,iEventsPerBlock);
            
            % concatenate the new event responses with the old responses vector
            allResponses = [allResponses responseTimeWithinEvent] ;
            
            Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
            Screen('Flip',Cfg.win);
            
            
            %% Event txt_Logfile
            fprintf(EventTxtLogFile,'%12.0f %12.0f %12.0f %18.0f %12.2f %12.5f %12.5f %12.5f \n',...
                iBlock,iEventsPerBlock,iEventDirection,iEventIsFixationTarget,iEventSpeed,eventOnsets(iBlock,iEventsPerBlock),eventEnds(iBlock,iEventsPerBlock),eventDurations(iBlock,iEventsPerBlock));
            
            % wait for the inter-stimulus interval
            WaitSecs(ExpParameters.ISI);
        end
        
        blockEnds(iBlock,1)= GetSecs-Cfg.Experiment_start;          % End of the block Time
        blockDurations(iBlock,1)= blockEnds(iBlock,1) - blockOnsets(iBlock,1); % Block Duration
        
        %Screen('DrawTexture',Cfg.win,imagesTex.Event(1));
        Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
        Screen('Flip',Cfg.win);
        
        WaitSecs(ExpParameters.IBI)
        
        %% Block txt_Logfile
        fprintf(BlockTxtLogFile,'%12.0f %12s %12f %12f %12f  \n',...
            iBlock,names{iBlock,1},blockOnsets(iBlock,1),blockEnds(iBlock,1),blockDurations(iBlock,1));
        
    end
    
    blockNames = names ;
    
    % End of the run for the BOLD to go down
    WaitSecs(ExpParameters.endDelay);
    
    % close txt log files
    fclose(BlockTxtLogFile);
    fclose(EventTxtLogFile);
    fclose(ResponsesTxtLogFile);
    
    
    TotalExperimentTime = GetSecs-Cfg.Experiment_start
    
    %% Save mat log files
    save(fullfile('logfiles',[subjectName,'_all.mat']))
    
    save(fullfile('logfiles',[subjectName,'.mat']),...
        'Cfg','allResponses','blockDurations','blockNames','blockOnsets')
    
    
    % Close the screen
    clear Screen;
    
catch              % if code crashes, closes serial port and screen
    clear Screen;
    
    error(lasterror) % show default error
end

