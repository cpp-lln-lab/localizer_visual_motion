%% Visual hMT localizer using translational motion in four directions
%  (up- down- left and right-ward)

% by Mohamed Rezk 2018
% adapted by MarcoB and RemiG 2020

%%

% Clear all the previous stuff
% clc; clear;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
addpath(genpath(fullfile(pwd, 'subfun')))

[ExpParameters, Cfg] = setParameters;

% set and load all the parameters to run the experiment
expParameters = userInputs(Cfg, ExpParameters);


%%  Experiment

% Safety loop: close the screen if code crashes
try
    %% Init the experiment
    [Cfg] = initPTB(Cfg);
    
    % Convert some values from degrees to pixels
    Cfg = deg2Pix('diameterAperture', Cfg, Cfg);
    ExpParameters = deg2Pix('dotSize', ExpParameters, Cfg);
    
    
    [el] = eyeTracker('Calibration', Cfg, ExpParameters);

    
    % % % REFACTOR THIS FUNCTION
    [ExpParameters] = expDesign(ExpParameters);
    % % %

    % Prepare for the output logfiles
    logFile = saveOutput(logFile, ExpParameters, 'open');


    % Prepare for fixation Cross
    if ExpParameters.Task1
        Cfg.xCoords = [-ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix 0 0] + ExpParameters.xDisplacementFixCross;
        Cfg.yCoords = [0 0 -ExpParameters.fixCrossDimPix ExpParameters.fixCrossDimPix] + ExpParameters.yDisplacementFixCross;
        Cfg.allCoords = [Cfg.xCoords; Cfg.yCoords];
    end    

    % Wait for space key to be pressed
    pressSpace4me
    
    getResponse('init', Cfg, ExpParameters, 1);
    
    getResponse('start', Cfg, ExpParameters, 1);
    
    % Show instructions
    if ExpParameters.Task1
        DrawFormattedText(Cfg.win,ExpParameters.TaskInstruction,...
            'center', 'center', Cfg.textColor);
        Screen('Flip', Cfg.win);
    end

    % Wait for Trigger from Scanner
    wait4Trigger(Cfg)
    
    % Show the fixation cross
    if ExpParameters.Task1
        drawFixationCross(Cfg, ExpParameters, ExpParameters.fixationCrossColor)
        Screen('Flip',Cfg.win);
    end
    
    %% Experiment Start
    Cfg.experimentStart = GetSecs;
    
    WaitSecs(ExpParameters.onsetDelay);
    
    %% For Each Block
    for iBlock = 1:ExpParameters.numBlocks
        
        fprintf('\n - Running Block %.0f \n',iBlock)

        [el] = eyeTracker('StartRecording', Cfg, ExpParameters);
        
        % For each event in the block
        for iEventsPerBlock = 1:ExpParameters.numEventsPerBlock
            
            % Check for experiment abortion from operator
            [keyIsDown, ~, keyCode] = KbCheck(Cfg.keyboard);
            if (keyIsDown==1 && keyCode(Cfg.escapeKey))
                break;
            end
            
            % Direction of that event
            logFile.iEventDirection = ExpParameters.designDirections(iBlock,iEventsPerBlock);
            % Speed of that event
            logFile.iEventSpeed = ExpParameters.designSpeeds(iBlock,iEventsPerBlock);
            
            
            % % % initially an input for DoDotMo func, now from
            % ExpParameters.eventDuration, to be tested
            % DODOTMO
            iEventDuration = ExpParameters.eventDuration ;                        % Duration of normal events
            % % %
            logFile.iEventIsFixationTarget = ExpParameters.designFixationTargets(iBlock,iEventsPerBlock);
            
            % Event Onset
            logFile.eventOnsets(iBlock,iEventsPerBlock) = GetSecs-Cfg.experimentStart;
            
            % play the dots
            doDotMo(Cfg, ExpParameters, logFile);
            
            
            %% logfile for responses
            
            responseEvents = getResponse('check', Cfg, ExpParameters);
            
            
            
            % concatenate the new event responses with the old responses vector
            %             logFile.allResponses = [logFile.allResponses responseTimeWithinEvent];
            
            
            
            %% Event End and Duration
            logFile.eventEnds(iBlock,iEventsPerBlock) = GetSecs-Cfg.experimentStart;
            logFile.eventDurations(iBlock,iEventsPerBlock) = logFile.eventEnds(iBlock,iEventsPerBlock) - logFile.eventOnsets(iBlock,iEventsPerBlock);

            % Save the events txt logfile
            logFile = saveOutput(logFile, ExpParameters, 'save', iBlock, iEventsPerBlock);
            
            % wait for the inter-stimulus interval
            WaitSecs(ExpParameters.ISI);
            
            getResponse('flush', Cfg, ExpParameters);
            
            
        end
        
        [el] = eyeTracker('StopRecordings', Cfg, ExpParameters);
        
        WaitSecs(ExpParameters.IBI);
        
    end
    
    % End of the run for the BOLD to go down
    WaitSecs(ExpParameters.endDelay);
    
    % Close the logfiles
    logFile = saveOutput(logFile, ExpParameters, 'close');

    TotalExperimentTime = GetSecs-Cfg.experimentStart;
    
    %% Save mat log files
    
    
    
    
    
    % % % ADD SESSION AND RUN NUMBER
    save(fullfile('logfiles',[ExpParameters.subjectNb,'_all.mat']))
    
    
    
    
    

    [el] = eyeTracker('Shutdown', Cfg, ExpParameters);

    getResponse('stop', Cfg, ExpParameters, 1);

    cleanUp()
    
catch
    
    cleanUp()
    psychrethrow(psychlasterror);
    
end

