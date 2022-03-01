function visualMotionLocalizer(cfg)
    %
    % (C) Copyright 2018 Mohamed Rezk
    % (C) Copyright 2020 CPP visual motion localizer developers

    if nargin < 1
        cfg = struct();
    end

    getOnlyPress = 1;

    % Clear all the previous stuff
    clc;
    if ~ismac
        close all;
        clear Screen;
    end

    % make sure we got access to all the required functions and inputs
    initEnv();

    % set and load all the parameters to run the experiment
    cfg = checkParameters(cfg);
    cfg = userInputs(cfg);
    cfg = createFilename(cfg);

    %%  Experiment

    % Safety loop: close the screen if code crashes
    try

        [cfg] = initPTB(cfg);

        cfg = postInitializationSetup(cfg);

        [el] = eyeTracker('Calibration', cfg);

        [cfg] = expDesign(cfg);

        % Prepare for the output logfiles with all
        logFile.extraColumns = cfg.extraColumns;
        logFile = saveEventsFile('init', cfg, logFile);
        logFile = saveEventsFile('open', cfg, logFile);

        % prepare textures
        cfg = apertureTexture('init', cfg);
        cfg = dotTexture('init', cfg);

        disp(cfg);

        % Show experiment instruction
        standByScreen(cfg);

        % prepare the KbQueue to collect responses
        getResponse('init', cfg.keyboard.responseBox, cfg);

        waitForTrigger(cfg);

        % Start
        eyeTracker('StartRecording', cfg);

        cfg = getExperimentStart(cfg);

        getResponse('start', cfg.keyboard.responseBox);

        waitFor(cfg, cfg.timing.onsetDelay);

        for iBlock = 1:cfg.design.nbBlocks

            fprintf('\n - Running Block %.0f \n', iBlock);

            eyeTracker('Message', cfg, ['start_block-', num2str(iBlock)]);

            dots = [];
            previousEvent.target = 0;

            for iEvent = 1:cfg.design.nbEventsPerBlock

                checkAbort(cfg, cfg.keyboard.keyboard);

                [thisEvent, thisFixation, cfg] = preTrialSetup(cfg, iBlock, iEvent);

                % we wait for a trigger every 2 events
                if cfg.pacedByTriggers.do && mod(iEvent, 2) == 1
                    waitForTrigger( ...
                                   cfg, ...
                                   cfg.keyboard.responseBox, ...
                                   cfg.pacedByTriggers.quietMode, ...
                                   cfg.pacedByTriggers.nbTriggers);
                end

                eyeTracker('Message', cfg, ...
                           ['start_trial-', num2str(iEvent), '_', thisEvent.trial_type]);

                % we only reuse the dots position for targets that consists of
                % presenting static dots with the same position as those of the
                % previous trial
                %
                % TODO does not take into account what to do if 3 or more targets in a row
                if strcmp(cfg.target.type, 'static_repeat') && ...
                   strcmp(thisEvent.trial_type, 'static') && ...
                   thisEvent.target == 1 && ...
                   thisEvent.target == previousEvent.target
                else
                    dots = [];
                end

                % play the dots and collect onset and duraton of the event
                [onset, duration, dots] = doDotMo(cfg, thisEvent, thisFixation, dots, iEvent);

                thisEvent = preSaveSetup( ...
                                         thisEvent, ...
                                         thisFixation, ...
                                         iBlock, iEvent, ...
                                         duration, onset, ...
                                         cfg, ...
                                         logFile);

                saveEventsFile('save', cfg, thisEvent);

                % collect the responses and appends to the event structure for
                % saving in the tsv file
                responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                                             getOnlyPress);

                triggerString = ['trigger_' cfg.design.blockNames{iBlock}];
                saveResponsesAndTriggers(responseEvents, cfg, logFile, triggerString);

                eyeTracker('Message', cfg, ...
                           ['end_trial-', num2str(iEvent), '_', thisEvent.trial_type]);

                previousEvent = thisEvent;

                waitFor(cfg, cfg.timing.ISI);

            end

            % "prepare" cross for the baseline block
            % if MT / MST this allows us to set the cross at the position of the next block
            if iBlock < cfg.design.nbBlocks
                nextBlock = iBlock + 1;
            else
                nextBlock = cfg.design.nbBlocks;
            end

            [~, thisFixation] = preTrialSetup(cfg, nextBlock, 1);
            drawFixation(thisFixation);
            Screen('Flip', cfg.screen.win);

            eyeTracker('Message', cfg, ['end_block-', num2str(iBlock)]);

            waitFor(cfg, cfg.timing.IBI);

            % IBI trigger paced
            if cfg.pacedByTriggers.do
                waitForTrigger( ...
                               cfg, ...
                               cfg.keyboard.responseBox, ...
                               cfg.pacedByTriggers.quietMode, ...
                               cfg.timing.triggerIBI);
            end

            if isfield(cfg.design, 'localizer') && ...
                strcmpi(cfg.design.localizer, 'MT_MST') && ...
                iBlock == cfg.design.nbBlocks / 2

                waitFor(cfg, cfg.timing.changeFixationPosition);

            end

            % trigger monitoring
            triggerEvents = getResponse('check', cfg.keyboard.responseBox, cfg, ...
                                        getOnlyPress);

            triggerString = 'trigger_baseline';
            saveResponsesAndTriggers(triggerEvents, cfg, logFile, triggerString);

        end

        % End of the run for the BOLD to go down
        waitFor(cfg, cfg.timing.endDelay);

        cfg = getExperimentEnd(cfg);

        eyeTracker('StopRecordings', cfg);

        % Close the logfiles
        saveEventsFile('close', cfg, logFile);

        getResponse('stop', cfg.keyboard.responseBox);
        getResponse('release', cfg.keyboard.responseBox);

        eyeTracker('Shutdown', cfg);

        createJson(cfg, cfg);

        farewellScreen(cfg);

        cleanUp();

    catch

        cleanUp();
        psychrethrow(psychlasterror);

    end

end
