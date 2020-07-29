%% Visual hMT localizer using translational motion in four directions
%  (up- down- left and right-ward)

% by Mohamed Rezk 2018
% adapted by MarcoB and RemiG 2020

%%

getOnlyPress = 1;

% Clear all the previous stuff
% clc; clear;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
initEnv();

[cfg, expParameters] = setParameters;

% set and load all the parameters to run the experiment
expParameters = userInputs(cfg, expParameters);
[cfg, expParameters] = createFilename(cfg, expParameters);

disp(expParameters);
disp(cfg);

% Prepare for fixation Cross
cfg.xCoords = [-expParameters.fixCrossDimPix expParameters.fixCrossDimPix 0 0] + ...
    expParameters.xDisplacementFixCross;
cfg.yCoords = [0 0 -expParameters.fixCrossDimPix expParameters.fixCrossDimPix] + ...
    expParameters.yDisplacementFixCross;
cfg.allCoords = [cfg.xCoords; cfg.yCoords];

%%  Experiment

% Safety loop: close the screen if code crashes
try

    %% Init the experiment
    [cfg] = initPTB(cfg);

    % Convert some values from degrees to pixels
    cfg = degToPix('diameterAperture', cfg, cfg);
    expParameters = degToPix('dotSize', expParameters, cfg);

    [el] = eyeTracker('Calibration', cfg, expParameters);

    % % % REFACTOR THIS FUNCTION
    [expParameters] = expDesign(expParameters);
    % % %

    % Prepare for the output logfiles with all
    logFile.extraColumns = expParameters.extraColumns;
    logFile = saveEventsFile('open', expParameters, logFile);

    % Wait for space key to be pressed
    pressSpaceForMe();

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);
    getResponse('start', cfg.keyboard.responseBox);

    % Show instructions
    DrawFormattedText(cfg.win, expParameters.taskInstruction, ...
        'center', 'center', cfg.textColor);
    Screen('Flip', cfg.win);

    % Wait for Trigger from Scanner
    waitForTrigger(cfg);

    % Show the fixation cross
    drawFixationCross(cfg, expParameters, expParameters.fixationCrossColor);
    Screen('Flip', cfg.win);

    %% Experiment Start
    cfg.experimentStart = GetSecs;

    WaitSecs(expParameters.onsetDelay);

    %% For Each Block

    for iBlock = 1:expParameters.numBlocks

        fprintf('\n - Running Block %.0f \n', iBlock);

        eyeTracker('StartRecording', cfg, expParameters);

        % For each event in the block
        for iEvent = 1:expParameters.numEventsPerBlock

            % Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            % set direction, speed of that event and if it is a target
            thisEvent.trial_type = 'dummy';
            thisEvent.direction = expParameters.designDirections(iBlock, iEvent);
            thisEvent.speed = expParameters.designSpeeds(iBlock, iEvent);
            thisEvent.target = expParameters.designFixationTargets(iBlock, iEvent);

            % play the dots and collect onset and duraton of the event
            [onset, duration] = doDotMo(cfg, expParameters, thisEvent);

            thisEvent.event = iEvent;
            thisEvent.block = iBlock;
            thisEvent.duration = duration;
            thisEvent.onset = onset - cfg.experimentStart;

            % Save the events txt logfile
            % we save event by event so we clear this variable every loop
            thisEvent.fileID = logFile.fileID;
            thisEvent.extraColumns = logFile.extraColumns;

            saveEventsFile('save', expParameters, thisEvent);
            
            clear thisEvent;

            % collect the responses and appends to the event structure for
            % saving in the tsv file
            responseEvents = collectAndSaveResponses(cfg, logFile, experimentStart);
            
            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, getOnlyPress);

            if isfield(responseEvents(1), 'onset') && ~isempty(responseEvents(1).onset)

                for iResp = 1:size(responseEvents, 1)
                    
                    responseEvents(iResp).event = iEvent;
                    responseEvents(iResp).block = iBlock;
                end

                saveEventsFile('save', expParameters, responseEvents);

            end

            % wait for the inter-stimulus interval
            WaitSecs(expParameters.ISI);

            getResponse('flush', cfg.keyboard.responseBox);

        end

        eyeTracker('StopRecordings', cfg, expParameters);

        WaitSecs(expParameters.IBI);

    end

    % End of the run for the BOLD to go down
    WaitSecs(expParameters.endDelay);

    % Close the logfiles
    saveEventsFile('close', expParameters, logFile);

    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);

    totalExperimentTime = GetSecs - cfg.experimentStart;

    eyeTracker('Shutdown', cfg, expParameters);

    % save the whole workspace
    matFile = fullfile( ...
        expParameters.outputDir, ...
        strrep(expParameters.fileName.events, 'tsv', 'mat'));
    if IsOctave
        save(matFile, '-mat7-binary');
    else
        save(matFile, '-v7.3');
    end

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
