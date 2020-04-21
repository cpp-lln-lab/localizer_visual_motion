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

[expParameters, cfg] = setParameters;

% set and load all the parameters to run the experiment
expParameters = userInputs(cfg, expParameters);
expParameters = createFilename(expParameters, cfg);

expParameters

%%  Experiment

% Safety loop: close the screen if code crashes
try
    
    
    %% Init the experiment
    [cfg] = initPTB(cfg);
    
    % Convert some values from degrees to pixels
    cfg = deg2Pix('diameterAperture', cfg, cfg);
    expParameters = deg2Pix('dotSize', expParameters, cfg);
    
    
    [el] = eyeTracker('Calibration', cfg, expParameters);

    
    % % % REFACTOR THIS FUNCTION
    [expParameters] = expDesign(expParameters);
    % % %

    % Prepare for the output logfiles with all
    logFile = saveEventsFile('open', expParameters, ...
        'direction', 'speed', 'isTarget', 'eventNb', 'blockNb');
    

    % Prepare for fixation Cross
    if expParameters.Task1
        
        cfg.xCoords = [-expParameters.fixCrossDimPix expParameters.fixCrossDimPix 0 0] ...
            + expParameters.xDisplacementFixCross;
        
        cfg.yCoords = [0 0 -expParameters.fixCrossDimPix expParameters.fixCrossDimPix] ...
            + expParameters.yDisplacementFixCross;
        
        cfg.allCoords = [cfg.xCoords; cfg.yCoords];
        
    end    

    % Wait for space key to be pressed
    pressSpace4me
    
    % prepare the KbQueue to collect responses
    getResponse('init', cfg, expParameters, 1);
    getResponse('start', cfg, expParameters, 1);
    
    % Show instructions
    if expParameters.Task1
        DrawFormattedText(cfg.win,expParameters.TaskInstruction,...
            'center', 'center', cfg.textColor);
        Screen('Flip', cfg.win);
    end

    % Wait for Trigger from Scanner
    wait4Trigger(cfg)
    
    % Show the fixation cross
    if expParameters.Task1
        drawFixationCross(cfg, expParameters, expParameters.fixationCrossColor)
        Screen('Flip',cfg.win);
    end
    
    
    %% Experiment Start
    cfg.experimentStart = GetSecs;
    
    WaitSecs(expParameters.onsetDelay);
    
    
    %% For Each Block
    
    stopEverything = 0;
    
    for iBlock = 1:expParameters.numBlocks
        
        if stopEverything
             break;
        end
        
        fprintf('\n - Running Block %.0f \n',iBlock)

        eyeTracker('StartRecording', cfg, expParameters);
        
        % For each event in the block
        for iEvent = 1:expParameters.numEventsPerBlock
            
            
            % Check for experiment abortion from operator
            [keyIsDown, ~, keyCode] = KbCheck(cfg.keyboard);
            if keyIsDown && keyCode(KbName(cfg.escapeKey))
                stopEverything = 1;
                warning('OK let us get out of here')
                break;
            end
            
            
            % direction speed of that event and if it is a target
            thisEvent.trial_type{1,1} = 'dummy';
            thisEvent.direction{1,1} = expParameters.designDirections(iBlock,iEvent);
            thisEvent.speed{1,1} = expParameters.designSpeeds(iBlock,iEvent);
            thisEvent.isTarget{1,1} = expParameters.designFixationTargets(iBlock,iEvent);

            % play the dots and collect onset and duraton of the event
            [onset, duration] = doDotMo(cfg, expParameters, thisEvent);

            thisEvent.eventNb{1,1} = iEvent;
            thisEvent.blockNb{1,1} = iBlock;
            thisEvent.duration{1,1} = duration;
            thisEvent.onset{1,1} = onset - cfg.experimentStart;
            
            
            % collect the responses and appends to the event structure for
            % saving in the tsv file
            responseEvents = getResponse('check', cfg, expParameters);
            
            if ~isempty(responseEvents)
                for iResp = 1:size(responseEvents, 1)
                    thisEvent.trial_type{end+1,1} = 'response';
                    thisEvent.duration{end+1,1} = 0;
                    thisEvent.direction{end+1,1} = [];
                    thisEvent.speed{end+1,1} = [];
                    thisEvent.isTarget{end+1,1} = expParameters.designFixationTargets(iBlock,iEvent);
                    thisEvent.eventNb{end+1,1} = iEvent;
                    thisEvent.blockNb{end+1,1} = iBlock;
                end
            end
            
            % Save the events txt logfile
            thisEvent.eventLogFile = logFile.eventLogFile;
            
            saveEventsFile('save', expParameters, thisEvent, ...
                'direction', 'speed', 'isTarget', 'eventNb', 'blockNb');

            % we save event by event so we clear this variable every loop
            clear thisEvent
            
            % wait for the inter-stimulus interval
            WaitSecs(expParameters.ISI);
            
            
            getResponse('flush', cfg, expParameters);
            
            
        end
        
        eyeTracker('StopRecordings', cfg, expParameters);
        
        WaitSecs(expParameters.IBI);
        
    end
    
    % End of the run for the BOLD to go down
    WaitSecs(expParameters.endDelay);
    
    % Close the logfiles
    saveEventsFile('close', expParameters, logFile);
    
    getResponse('stop', cfg, expParameters, 1);

    totalExperimentTime = GetSecs-cfg.experimentStart;
    
    eyeTracker('Shutdown', cfg, expParameters);

    % save the whole workspace
    matFile = fullfile(expParameters.outputDir, strrep(expParameters.fileName.events,'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end

    cleanUp()
    
catch
    
    cleanUp()
    psychrethrow(psychlasterror);
    
end
