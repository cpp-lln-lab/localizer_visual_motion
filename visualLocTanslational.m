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

%%  Experiment

% Safety loop: close the screen if code crashes
try

    %% Init the experiment
    [cfg] = initPTB(cfg);

    cfg.dot.matrixWidth = cfg.screen.winHeight;

    % Convert some values from degrees to pixels
    cfg.dot = degToPix('size', cfg.dot, cfg);
    cfg.dot = degToPix('speed', cfg.dot, cfg);

    % Get dot speeds in pixels per frame
    cfg.dot.speedPixPerFrame = cfg.dot.speedPix / cfg.screen.monitorRefresh;

    cfg.aperture = degToPix('xPos', cfg.aperture, cfg);

    % dots are displayed on a square with a length in visual angle equal to the
    % field of view
    cfg.dot.number = round(cfg.dot.density * ...
        (cfg.dot.matrixWidth / cfg.screen.ppd)^2);

    [el] = eyeTracker('Calibration', cfg);

    [cfg] = expDesign(cfg);

    % Prepare for the output logfiles with all
    logFile.extraColumns = cfg.extraColumns;
    logFile = saveEventsFile('open', cfg, logFile);

    % prepare textures
    cfg = apertureTexture('init', cfg);
    cfg = dotTexture('init', cfg);

    disp(cfg);

    standByScreen(cfg);

    % prepare the KbQueue to collect responses
    getResponse('init', cfg.keyboard.responseBox, cfg);

    % Wait for Trigger from Scanner
    waitForTrigger(cfg);

    %% Experiment Start
    cfg = getExperimentStart(cfg);
    
    getResponse('start', cfg.keyboard.responseBox);

    WaitSecs(cfg.onsetDelay);

    %% For Each Block

    for iBlock = 1:cfg.design.nbBlocks

        fprintf('\n - Running Block %.0f \n', iBlock);

        eyeTracker('StartRecording', cfg);

        % For each event in the block
        for iEvent = 1:cfg.design.nbEventsPerBlock

            % Check for experiment abortion from operator
            checkAbort(cfg, cfg.keyboard.keyboard);

            % set direction, speed of that event and if it is a target
            thisEvent.trial_type = cfg.design.blockNames{iBlock};
            thisEvent.direction = cfg.design.directions(iBlock, iEvent);
            thisEvent.speed = cfg.design.speeds(iBlock, iEvent);
            thisEvent.target = cfg.design.fixationTargets(iBlock, iEvent);

            % play the dots and collect onset and duraton of the event
            [onset, duration] = doDotMo(cfg, thisEvent);

            thisEvent.event = iEvent;
            thisEvent.block = iBlock;
            thisEvent.keyName = 'n/a';
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
            responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                getOnlyPress);

            if isfield(responseEvents(1), 'onset') && ~isempty(responseEvents(1).onset)

                for iResp = 1:size(responseEvents, 1)
                    responseEvents(iResp).onset = ...
                        responseEvents(iResp).onset - cfg.experimentStart;
                    responseEvents(iResp).event = 'n/a';
                    responseEvents(iResp).block = 'n/a';
                    responseEvents(iResp).direction = 'n/a';
                    responseEvents(iResp).speed = 'n/a';
                    responseEvents(iResp).target = 'n/a';
                    if strcmp(responseEvents(iResp).keyName, 't')
                        responseEvents(iResp).trial_type = ...
                            ['trigger_' cfg.design.blockNames{iBlock}];
                    end
                end

                responseEvents(1).fileID = logFile.fileID;
                responseEvents(1).extraColumns = logFile.extraColumns;
                saveEventsFile('save', cfg, responseEvents);

            end

            % wait for the inter-stimulus interval
            WaitSecs(cfg.ISI);

        end

        eyeTracker('StopRecordings', cfg);

        WaitSecs(cfg.IBI);

        % trigger monitoring
        triggerEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
            getOnlyPress);

        if isfield(triggerEvents(1), 'onset') && ~isempty(triggerEvents(1).onset)

            for iResp = 1:size(triggerEvents, 1)
                triggerEvents(iResp).onset = ...
                    triggerEvents(iResp).onset - cfg.experimentStart;
                triggerEvents(iResp).event = 'n/a';
                triggerEvents(iResp).block = 'n/a';
                triggerEvents(iResp).direction = 'n/a';
                triggerEvents(iResp).speed = 'n/a';
                triggerEvents(iResp).target = 'n/a';
                if strcmp(triggerEvents(iResp).keyName, 't')
                    triggerEvents(iResp).trial_type = 'trigger_baseline';
                end
            end

            triggerEvents(1).fileID = logFile.fileID;
            triggerEvents(1).extraColumns = logFile.extraColumns;
            saveEventsFile('save', cfg, triggerEvents);

        end

    end

    % End of the run for the BOLD to go down
    WaitSecs(cfg.endDelay);

    cfg = getExperimentEnd(cfg);

    % Close the logfiles
    saveEventsFile('close', cfg, logFile);

    getResponse('stop', cfg.keyboard.responseBox);
    getResponse('release', cfg.keyboard.responseBox);

    eyeTracker('Shutdown', cfg);

    createBoldJson(cfg, cfg);

    farewellScreen(cfg);

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
