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
    
    [ExpParameters, Cfg]  = VisualDegree2Pixels(ExpParameters);
    
    % % % REFACTOR THIS FUNCTION
    [ExpDesignParameters] = ExpDesign(Cfg);
    % % %
    
    % Visual degree to pixels converter
    [ExpParameters, Cfg] = VisualDegree2Pixels(ExpParameters, Cfg);
    
    % Prepare for the output logfiles
    saveOutput(subjectName, Cfg, ExpParameters, 'open')
    
    % Empty vectors and matrices for speed
    blockNames     = cell(ExpParameters.numBlocks,1);
    logFile.blockOnsets    = zeros(ExpParameters.numBlocks,1);
    logFile.blockEnds      = zeros(ExpParameters.numBlocks,1);
    logFile.blockDurations = zeros(ExpParameters.numBlocks,1);
    
    logFile.eventOnsets    = zeros(ExpParameters.numBlocks,ExpParameters.numEventsPerBlock);
    logFile.eventEnds      = zeros(ExpParameters.numBlocks,ExpParameters.numEventsPerBlock);
    logFile.eventDurations = zeros(ExpParameters.numBlocks,ExpParameters.numEventsPerBlock);
    
    allResponses = [] ;
    
    % % % PUT IT RIGHT BEFORE STARTING THE EXPERIMENT
    % Show instructions
    if ExpParameters.Task1
        DrawFormattedText(Cfg.win,ExpParameters.TaskInstruction,...
            'center', 'center', Cfg.textColor);
        Screen('Flip', Cfg.win);
    end
    % % %
    
    % Prepare for fixation Cross
    if ExpParameters.Task1
        xCoords = [-ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix 0 0] + ExpParameters.xDisplacementFixCross;
        yCoords = [0 0 -ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix] + ExpParameters.yDisplacementFixCross;
        Cfg.allCoords = [xCoords; yCoords];
    end
    
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
    
    %% Experiment Start
    Cfg.Experiment_start = GetSecs;
    
    WaitSecs(ExpParameters.onsetDelay);
    
    %% For Each Block
    for iBlock = 1:ExpParameters.numBlocks
        
        fprintf('Running Block %.0f \n',iBlock)
        
        logFile.blockOnsets(iBlock,1)= GetSecs-Cfg.Experiment_start;
        
        % For each event in the block
        for iEventsPerBlock = 1:ExpParameters.numEventsPerBlock
            
            logFile.iEventDirection = ExpDesignParameters.directions(iBlock,iEventsPerBlock);       % Direction of that event
            logFile.iEventSpeed = ExpDesignParameters.speeds(iBlock,iEventsPerBlock);               % Speed of that event
            iEventDuration = ExpParameters.eventDuration ;                        % Duration of normal events
            logFile.iEventIsFixationTarget = ExpDesignParameters.fixationTargets(iBlock,iEventsPerBlock);
            
            % Event Onset
            logFile.eventOnsets(iBlock,iEventsPerBlock) = GetSecs-Cfg.Experiment_start;
            
            % play the dots
            responseTimeWithinEvent = DoDotMo( Cfg, logFile.iEventDirection, logFile.iEventSpeed, iEventDuration, logFile.iEventIsFixationTarget);
            
            %% logfile for responses
            if ~isempty(responseTimeWithinEvent)
                fprintf(ResponsesTxtLogFile,'%8.6f \n',responseTimeWithinEvent);
            end
            
            %% Event End and Duration
            logFile.eventEnds(iBlock,iEventsPerBlock) = GetSecs-Cfg.Experiment_start;
            logFile.eventDurations(iBlock,iEventsPerBlock) = logFile.eventEnds(iBlock,iEventsPerBlock) - logFile.eventOnsets(iBlock,iEventsPerBlock);
            
            % concatenate the new event responses with the old responses vector
            allResponses = [allResponses responseTimeWithinEvent] ; %#ok<AGROW>
            
            Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
            Screen('Flip',Cfg.win);
            
            
            
            
            
            % Save the events txt logfile
            SaveOutput(logFile, ExpDesignParameters, 'save Events')
       
            
            
            % wait for the inter-stimulus interval
            WaitSecs(ExpParameters.ISI);
        end
        
        logFile.blockEnds(iBlock,1)= GetSecs-Cfg.Experiment_start;          % End of the block Time
        logFile.blockDurations(iBlock,1)= logFile.blockEnds(iBlock,1) - logFile.blockOnsets(iBlock,1); % Block Duration
        
        %Screen('DrawTexture',Cfg.win,imagesTex.Event(1));
        Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, [255 255 255] , [Cfg.center(1) Cfg.center(2)], 1);
        Screen('Flip',Cfg.win);
        
        WaitSecs(ExpParameters.IBI)
        
        % Save the block txt Logfile
        SaveOutput(logFile, ExpDesignParameters, 'save Blocks')

    end
    
    blockNames = ExpDesignParameters.blockNames ;
    
    % End of the run for the BOLD to go down
    WaitSecs(ExpParameters.endDelay);
    
    % close txt log files
    fclose(BlockTxtLogFile);
    fclose(EventTxtLogFile);
    fclose(ResponsesTxtLogFile);
    
    
    TotalExperimentTime = GetSecs-Cfg.Experiment_start;
    
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

