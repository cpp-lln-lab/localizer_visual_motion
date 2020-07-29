%% Visual hMT localizer using translational motion in four directions
%  (up- down- left and right-ward)

% by Mohamed Rezk 2018
% adapted by MarcoB and RemiG 2020

%%

getOnlyPress = 1;

more off;

% Clear all the previous stuff
% clc; clear;
if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
initEnv();

% set and load all the parameters to run the experiment
cfg = setParameters;
cfg = userInputs(cfg);
cfg = createFilename(cfg);

disp(cfg);

% REFACTOR
% Prepare for fixation Cross
cfg.xCoords = [-cfg.fixation.dimensionPix cfg.fixation.dimensionPix 0 0] + ...
    cfg.fixation.xDisplacement;
cfg.yCoords = [0 0 -cfg.fixation.dimensionPix cfg.fixation.dimensionPix] + ...
    cfg.fixation.yDisplacement;
cfg.allCoords = [cfg.xCoords; cfg.yCoords];

%%  Experiment

% Safety loop: close the screen if code crashes
try

    %% Init the experiment
    [cfg] = initPTB(cfg);

    % Convert some values from degrees to pixels
    cfg = degToPix('diameterAperture', cfg, cfg);
    cfg.dot = degToPix('size', cfg.dot, cfg);

    [el] = eyeTracker('Calibration', cfg);

    % % % REFACTOR THIS FUNCTION
    [cfg] = expDesign(cfg);
    % % %

    % Prepare for the output logfiles with all
    logFile.extraColumns = cfg.extraColumns;
    logFile = saveEventsFile('open', cfg, logFile);

    % Wait for space key to be pressed
    pressSpaceForMe();

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);
    getResponse('start', cfg.keyboard.responseBox);

    % Show instructions
    DrawFormattedText(cfg.screen.win, cfg.task.instruction, ...
        'center', 'center', cfg.text.color);
    Screen('Flip', cfg.screen.win);

    % Wait for Trigger from Scanner
    waitForTrigger(cfg);

    % Show the fixation cross
    drawFixationCross(cfg, cfg.fixation.color);
    Screen('Flip', cfg.screen.win);

    %% Experiment Start
    cfg.experimentStart = GetSecs;

    WaitSecs(cfg.onsetDelay);

    %% For Each Block

    for iBlock = 1:cfg.numBlocks

        fprintf('\n - Running Block %.0f \n', iBlock);

        eyeTracker('StartRecording', cfg);

        % For each event in the block
        for iEvent = 1:cfg.numEventsPerBlock

            % Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            % set direction, speed of that event and if it is a target
            thisEvent.trial_type = 'dummy';
            thisEvent.direction = cfg.design.directions(iBlock, iEvent);
            thisEvent.speed = cfg.design.speeds(iBlock, iEvent);
            thisEvent.target = cfg.design.fixationTargets(iBlock, iEvent);

            % play the dots and collect onset and duraton of the event
            [onset, duration] = doDotMo(cfg, thisEvent);

            thisEvent.event = iEvent;
            thisEvent.block = iBlock;
            thisEvent.duration = duration;
            thisEvent.onset = onset - cfg.experimentStart;

            % Save the events txt logfile
            % we save event by event so we clear this variable every loop
            thisEvent.fileID = logFile.fileID;
            thisEvent.extraColumns = logFile.extraColumns;

            saveEventsFile('save', cfg, thisEvent);

            clear thisEvent;

            % collect the responses and appends to the event structure for
            % saving in the tsv file
            responseEvents = collectAndSaveResponses(cfg, logFile, cfg.experimentStart);

            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, getOnlyPress);

            if isfield(responseEvents(1), 'onset') && ~isempty(responseEvents(1).onset)

                for iResp = 1:size(responseEvents, 1)

                    responseEvents(iResp).event = iEvent;
                    responseEvents(iResp).block = iBlock;
                end

                saveEventsFile('save', cfg, responseEvents);

            end

            % wait for the inter-stimulus interval
            WaitSecs(cfg.ISI);

            getResponse('flush', cfg.keyboard.responseBox);

        end

        eyeTracker('StopRecordings', cfg);

        WaitSecs(cfg.IBI);

    end

    % End of the run for the BOLD to go down
    WaitSecs(cfg.endDelay);

    % Close the logfiles
    saveEventsFile('close', cfg, logFile);

    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);

    totalExperimentTime = GetSecs - cfg.experimentStart;

    eyeTracker('Shutdown', cfg);

    % save the whole workspace
    matFile = fullfile( ...
        cfg.dir.output, ...
        strrep(cfg.fileName.events, 'tsv', 'mat'));
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
