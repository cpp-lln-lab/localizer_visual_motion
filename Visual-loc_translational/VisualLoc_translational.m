%% Visual hMT localizer using translational motion in four directions
%  (up- down- left and right-ward)

% by Mohamed Rezk 2018
% adapted by MarcoB 2020


% % % Different duratons for different number of repetitions (may add a few TRs to this number just for safety)
% % % Cfg.numRepetitions=7, Duration: 345.77 secs (5.76 mins), collect 139 + 4 Triggers = 143 TRs at least per run
% % % Cfg.numRepetitions=6, Duration: 297.86 secs (4.96 mins), collect 120 + 4 Triggers = 124 TRs at least per run
% % % Cfg.numRepetitions=5, Duration: 249.91 secs (4.17 mins), collect 100 + 4 Triggers = 104 TRs at least per run
% % % Cfg.numRepetitions=4, Duration: 201.91 secs (3.37 mins), collect 81 + 4 Triggers  = 85  TRs at least per run

%%

% Clear all the previous stuff
% clc; clear;
if ~ismac
    close all;
    clear Screen;
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
    
    % Fixation Cross
    if ExpParameters.Task1
        xCoords = [-ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix 0 0] + ExpParameters.xDisplacementFixCross;
        yCoords = [0 0 -ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix] + ExpParameters.yDisplacementFixCross;
        Cfg.allCoords = [xCoords; yCoords];
    end
    
    [ExpParameters, Cfg]  = VisualDegree2Pixels(ExpParameters, Cfg);
    
    % % % TO ME NOT NECESSARY see later
    directions=[];
    speeds=[];
    fixationTargets=[];
    % % %
    
    % % % REFACTOR THIS FUNCTION
    [directions, speeds, fixationTargets, names] = experimentalDesign(Cfg);
    % % %
    
    % Visual degree to pixels converter
    [ExpParameters, Cfg] = VisualDegree2Pixels(ExpParameters, Cfg);
    
    % Empty vectors and matrices for speed
    blockNames     = cell(ExpParameters.numBlocks,1);
    blockOnsets    = zeros(ExpParameters.numBlocks,1);
    blockEnds      = zeros(ExpParameters.numBlocks,1);
    blockDurations = zeros(ExpParameters.numBlocks,1);
    
    eventOnsets    = zeros(ExpParameters.numBlocks,ExpParameters.numEventsPerBlock);
    eventEnds      = zeros(ExpParameters.numBlocks,ExpParameters.numEventsPerBlock);
    eventDurations = zeros(ExpParameters.numBlocks,ExpParameters.numEventsPerBlock);
    
    allResponses = [] ;
    
    % % % PUT IT RIGHT BEFORE STARTING THE EXPERIMENT
    % Show instructions
    if ExpParameters.Task1
        DrawFormattedText(Cfg.win,ExpParameters.TaskInstruction,...
            'center', 'center', Cfg.textColor);
        Screen('Flip', Cfg.win);
    end
    % % %
    
    % Wait for space key to be pressed
    pressSpace4me
    
    % Wait for Trigger from Scanner
    Wait4Trigger(Cfg)
    
    % Show the fixation cross
    if ExpParameters.Task1
        Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, ...
            [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
        Screen('Flip',Cfg.win);
    end
    

    
    BlockTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_Blocks.txt']),'w');
    fprintf(BlockTxtLogFile,'%12s  %12s %12s %12s %12s \n', ...
        'BlockNumber', ...
        'Condition', ...
        'Onset', ...
        'End', ...
        'Duration');
    
    EventTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_Events.txt']),'w');
    fprintf(EventTxtLogFile,'%12s %12s %12s %18s %12s %12s %12s %12s \n', ...
        'BlockNumber', ...
        'EventNumber', ...
        'Direction', ...
        'IsFixationTarget', ...
        'Speed', ...
        'Onset', ...
        'End', ...
        'Duration');
    
    ResponsesTxtLogFile = fopen(fullfile('logfiles',[subjectName,'_Responses.txt']),'w');
    fprintf(ResponsesTxtLogFile,'%12s \n', ...
        'Responses');
    
    %% Experiment Start
    Cfg.Experiment_start = GetSecs;
    
    WaitSecs(ExpParameters.onsetDelay);
    
    %% For Each Block
    for iBlock = 1:ExpParameters.numBlocks
        
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
        'Cfg', ...
        'allResponses', ...
        'blockDurations', ...
        'blockNames', ...
        'blockOnsets')
    
    
    % Close the screen
    sca
    clear Screen;
    
catch
    % if code crashes, closes serial port and screen
    sca
    clear Screen;
    error(lasterror) % show default error
end

