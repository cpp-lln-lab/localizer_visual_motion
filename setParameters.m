% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = setParameters()

    % VISUAL LOCALIZER

    % Initialize the parameters and general configuration variables
    cfg = struct();

    % by default the data will be stored in an output folder created where the
    % setParamters.m file is
    % change that if you want the data to be saved somewhere else
    cfg.dir.output = fullfile( ...
                              fileparts(mfilename('fullpath')), 'output');

    %% Debug mode settings

    cfg.debug.do = false; % To test the script out of the scanner, skip PTB sync
    cfg.debug.smallWin = false; % To test on a part of the screen, change to 1
    cfg.debug.transpWin = false; % To test with trasparent full size screen

    cfg.skipSyncTests = 0;

    cfg.verbose = 1;

    %% Engine parameters

    cfg.testingDevice = 'mri';
    cfg.eyeTracker.do = true;
    cfg.audio.do = false;

    cfg = setMonitor(cfg);

    % Keyboards
    cfg = setKeyboards(cfg);

    % MRI settings
    cfg = setMRI(cfg);
    %     cfg.suffix.acquisition = '';

    cfg.pacedByTriggers.do = true;

    %% Experiment Design

    % switching this on to MT or MT/MST with use:
    % - MT: translational motion on the whole screen
    %   - alternates static and motion (left or right) blocks
    % - MST: radial motion centered in a circle aperture that is on the opposite
    % side of the screen relative to the fixation
    %   - alternates fixaton left and fixation right
    cfg.design.localizer = 'MT';
    %     cfg.design.localizer = 'MT_MST';

    cfg.design.motionType = 'translation';
    cfg.design.motionDirections = [0 0 180 180];
    cfg.design.names = {'static'; 'motion'};

    % if you have static and motion and `nbRepetions` = 4, this will return 8 blocks (n blocks per
    % hemifield in case of MT/MST localizer)
    cfg.design.nbRepetitions = 10;
    cfg.design.nbEventsPerBlock = 10;

    %% Timing

    % FOR 7T: if you want to create localizers on the fly, the following must be
    % multiples of the scanneryour sequence TR
    %
    % IBI
    % block length = (cfg.eventDuration + cfg.ISI) * cfg.design.nbEventsPerBlock

    cfg.timing.eventDuration = 0.30; % second

    % Time between blocs in secs
    cfg.timing.IBI = 0;
    % Time between events in secs
    cfg.timing.ISI = 0;
    % Number of seconds before the motion stimuli are presented
    cfg.timing.onsetDelay = 0;
    % Number of seconds after the end all the stimuli before ending the run
    cfg.timing.endDelay = 3.6;

    % reexpress those in terms of repetition time
    if cfg.pacedByTriggers.do

        cfg.pacedByTriggers.quietMode = true;
        cfg.pacedByTriggers.nbTriggers = 1;

        cfg.timing.eventDuration = cfg.mri.repetitionTime / 2 - 0.04; % second

        % Time between blocs in nb of triggers (remember to consider the nb trigger to wait + 1)
        cfg.timing.triggerIBI = 4;
        % Time between blocks in secs
        cfg.timing.IBI = 0;
        % Time between events in secs
        cfg.timing.ISI = 0;
        % Number of seconds before the motion stimuli are presented
        cfg.timing.onsetDelay = 0;
        % Number of seconds after the end all the stimuli before ending the run
        cfg.timing.endDelay = 2;

    end

    %% Visual Stimulation

    % Speed in visual angles / second
    cfg.dot.speed = 15;
    % Coherence Level (0-1)
    cfg.dot.coherence = 1;
    % Number of dots per visual angle square.
    cfg.dot.density = 1;
    % Dot life time in seconds
    cfg.dot.lifeTime = 0.4;
    % proportion of dots killed per frame
    cfg.dot.proportionKilledPerFrame = 0;
    % Dot Size (dot width) in visual angles.
    cfg.dot.size = .2;
    cfg.dot.color = cfg.color.white;

    % Diameter/length of side of aperture in Visual angles
    cfg.aperture.type = 'none';
    cfg.aperture.width = []; % if left empty it will take the screen height
    cfg.aperture.xPos = 0;

    %% Task(s)

    cfg.task.name = 'visual localizer';

    % Instruction
    cfg.task.instruction = '1-Detect the RED fixation cross\n \n\n';

    % Fixation cross (in pixels)
    cfg.fixation.type = 'cross';
    cfg.fixation.colorTarget = cfg.color.red;
    cfg.fixation.color = cfg.color.white;
    cfg.fixation.width = .25;
    cfg.fixation.lineWidthPix = 3;
    cfg.fixation.xDisplacement = 0;
    cfg.fixation.yDisplacement = 0;

    % target
    cfg.target.maxNbPerBlock = 1;
    cfg.target.duration = 0.1; % In secs
    cfg.target.type = 'fixation_cross';
    % 'fixation_cross' : the fixation cross changes color
    % 'static_repeat' : dots are in the same position

    cfg.extraColumns = { ...
                        'direction', ...
                        'speedDegVA', ...
                        'target', ...
                        'event', ...
                        'block', ...
                        'keyName', ...
                        'fixationPosition', ...
                        'aperturePosition'};

    %% orverrireds the relevant fields in case we use the MT / MST localizer
    cfg = setParametersMtMst(cfg);

end

function cfg = setKeyboards(cfg)
    cfg.keyboard.escapeKey = 'ESCAPE';
    cfg.keyboard.responseKey = { ...
                                'r', 'g', 'y', 'b', ...
                                'd', 'n', 'z', 'e', ...
                                't'};
    cfg.keyboard.keyboard = [];
    cfg.keyboard.responseBox = [];

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.keyboard.keyboard = [];
        cfg.keyboard.responseBox = [];
    end
end

function cfg = setMRI(cfg)
    % letter sent by the trigger to sync stimulation and volume acquisition
    cfg.mri.triggerKey = 't';
    cfg.mri.triggerNb = 5;

    cfg.mri.repetitionTime = 1.8;

    cfg.bids.MRI.Instructions = 'Detect the RED fixation cross';
    cfg.bids.MRI.TaskDescription = [];

end

function cfg = setMonitor(cfg)

    % Monitor parameters for PTB
    cfg.color.white = [255 255 255];
    cfg.color.black = [0 0 0];
    cfg.color.red = [255 0 0];
    cfg.color.grey = mean([cfg.color.black; cfg.color.white]);
    cfg.color.background = cfg.color.black;
    cfg.text.color = cfg.color.white;

    % Monitor parameters
    cfg.screen.monitorWidth = 50; % in cm
    cfg.screen.monitorDistance = 40; % distance from the screen in cm

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.screen.monitorWidth = 25;
        cfg.screen.monitorDistance = 95;
    end

end

function cfg = setParametersMtMst(cfg)

    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

        cfg.task.name = 'mt mst localizer';

        cfg.design.motionType = 'radial';
        cfg.design.motionDirections = [666 -666];
        %         cfg.design.names = {'motion'};
        cfg.design.names = {'static'; 'motion'};
        cfg.design.fixationPosition = {'fixation_left'; 'fixation_right'};
        %          cfg.design.fixationPosition = {'fixation_right'; 'fixation_left'};
        cfg.design.xDisplacementFixation = 7;
        cfg.design.xDisplacementAperture = 3;

        % here we double the repetions (2 hemifields)
        cfg.design.nbRepetitions = cfg.design.nbRepetitions * length(cfg.design.fixationPosition);

        % inward&outward are presented as separated event
        cfg.design.nbEventsPerBlock = cfg.design.nbEventsPerBlock * 2;

        cfg.timing.IBI = 4;

        cfg.timing.changeFixationPosition = 10;

        % reexpress those in terms of repetition time
        if cfg.pacedByTriggers.do

            cfg.timing.IBI = 2;

        end

        cfg.aperture.type = 'circle';
        cfg.aperture.width = 7; % if left empty it will take the screen height
        cfg.aperture.xPos = cfg.design.xDisplacementAperture;

    end

end
