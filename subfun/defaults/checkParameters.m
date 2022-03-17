function [cfg] = checkParameters(cfg)
    %
    % Check that all parameters are sets. If not it uses the defaults.
    %
    % ``cfg.design.localizer``: switching this to ``MT`` (default) or ``MT_MST``
    %
    % - ``MT``: translational motion on the whole screen
    %
    %   - alternates static and motion (left or right) blocks
    %
    % - ``MT_MST``: radial motion centered in a circle aperture that is on the opposite
    %   side of the screen relative to the fixation
    %
    %   - (default) alternates fixaton left and fixation right
    %
    % ``cfg.dir.output``: by default the data will be stored in an output folder created in the root
    % dir of this repo. Change that if you want the data to be saved somewhere
    % else.
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    % Initialize the general configuration variables structure
    if nargin < 1
        cfg.design.localizer = 'MT';
    end

    root_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..');
    if which('bids.internal.file_utils')
        root_dir = bids.internal.file_utils(root_dir, 'cpath');
    end

    % the "source" subfolder will be added by createFilename of CPP_BIDS
    fieldsToSet.dir.output = fullfile(root_dir, 'output');

    %% Engine parameters
    fieldsToSet.testingDevice = 'mri';
    fieldsToSet.eyeTracker.do = false;

    fieldsToSet = setMonitor(fieldsToSet);

    fieldsToSet = setKeyboards(fieldsToSet);

    %% Experiment Design

    % if you have static and motion and `nbRepetions` = 4, this will return 8 blocks (for MT/MST
    % localizer && 2 hemifield it is 8 blocks per hemifield), i.e. how many times each condition
    % will be repeated
    fieldsToSet.design.nbRepetitions = 12;
    fieldsToSet.design.nbEventsPerBlock = 12;

    %% Timing

    % block length = (cfg.eventDuration + cfg.ISI) * cfg.design.nbEventsPerBlock
    fieldsToSet.timing.eventDuration = 0.6; % second

    % Time between events in secs
    fieldsToSet.timing.ISI = 0.1;
    % Number of seconds before the motion stimuli are presented
    fieldsToSet.timing.onsetDelay = 5;
    % Number of seconds after the end all the stimuli before ending the run
    fieldsToSet.timing.endDelay = 5;

    %% Visual Stimulation
    fieldsToSet.dot = cppPtbDefaults('dot');
    fieldsToSet.dot.color = fieldsToSet.color.white;

    %% Task(s)

    % target
    % 'fixation_cross' : the fixation cross changes color
    % 'static_repeat' : static dots are in the same position as previous trials
    fieldsToSet.target.type = 'fixation_cross';

    % Fixation cross (in pixels)
    fieldsToSet.fixation = cppPtbDefaults('fixation');
    fieldsToSet.fixation.color = fieldsToSet.color.white;
    fieldsToSet.fixation.width = .25;
    fieldsToSet.fixation.lineWidthPix = 3;

    fieldsToSet.extraColumns = {'direction', ...
                                'speedDegVA', ...
                                'target', ...
                                'event', ...
                                'block', ...
                                'keyName', ...
                                'fixationPosition', ...
                                'aperturePosition'};

    fieldsToSet.audio.do = false;

    cfg = setDefaultFields(cfg, fieldsToSet);

    cfg = setParametersMtMst(cfg);

    cfg = setMRI(cfg);

    cfg = setTarget(cfg);

    cfg = checkCppPtbCfg(cfg);

    if cfg.verbose == 2
        unfold(cfg);
    end

end

function fieldsToSet = setKeyboards(fieldsToSet)

    fieldsToSet.keyboard = cppPtbDefaults('keyboard');

    fieldsToSet.keyboard.responseKey = {'r', 'g', 'y', 'b', ...
                                        'd', 'n', 'z', 'e', ...
                                        't'};

end

function cfg = setMRI(cfg)

    % letter sent by the trigger to sync stimulation and volume acquisition
    fieldsToSet.mri.triggerKey = 't';

    fieldsToSet.mri.triggerNb = 5;

    fieldsToSet.mri.repetitionTime = 1.8;

    fieldsToSet.suffix.acq = '';

    fieldsToSet.pacedByTriggers.do = false;

    cfg = setDefaultFields(cfg, fieldsToSet);

    cfg = setPacedByTrigger(cfg);

end

function fieldsToSet = setMonitor(fieldsToSet)

    % Monitor parameters for PTB
    fieldsToSet.color = cppPtbDefaults('color');
    fieldsToSet.color.background = fieldsToSet.color.black;
    fieldsToSet.text.color = fieldsToSet.color.white;

    % Monitor parameters
    fieldsToSet.screen.monitorWidth = 50; % in cm
    fieldsToSet.screen.monitorDistance = 40; % distance from the screen in cm
    if strcmpi(fieldsToSet.testingDevice, 'mri')
        fieldsToSet.screen.monitorWidth = 25;
        fieldsToSet.screen.monitorDistance = 95;
    end

end

function cfg = setParametersMtMst(cfg)

    switch lower(cfg.design.localizer)

        case 'mt_mst'

            fieldsToSet.task.name = 'mt mst localizer';

            fieldsToSet.design.motionType = 'radial';
            fieldsToSet.design.motionDirections = [666 -666];
            fieldsToSet.design.names = {'motion'};
            % {'static'; 'motion'}
            fieldsToSet.design.fixationPosition = {'fixation_right'; 'fixation_left'};
            % {'fixation_right'; 'fixation_left'};
            fieldsToSet.design.xDisplacementFixation = 7;
            fieldsToSet.design.xDisplacementAperture = 3;

            % inward and outward are presented as separated event
            fieldsToSet.design.nbEventsPerBlock = cfg.design.nbEventsPerBlock * 2;

            % time between events in secs
            fieldsToSet.timing.ISI = 0;
            fieldsToSet.timing.IBI = 10;
            fieldsToSet.timing.changeFixationPosition = 10;

            fieldsToSet.aperture.type = 'circle';
            fieldsToSet.aperture.width = 7; % if left empty it will take the screen height
            fieldsToSet.aperture.xPos = fieldsToSet.design.xDisplacementAperture;

        case 'mt'

            fieldsToSet.task.name = 'visual localizer';

            fieldsToSet.design.motionType = 'translation';
            fieldsToSet.design.motionDirections = [0 0 180 180];
            fieldsToSet.design.names = {'static'; 'motion'};

            % Time between blocs in secs
            fieldsToSet.timing.IBI = 4;

            % Diameter/length of side of aperture in Visual angles
            fieldsToSet.aperture.type = 'none';
            fieldsToSet.aperture.width = []; % if left empty it will take the screen height
            fieldsToSet.aperture.xPos = 0;

    end

    cfg = setDefaultFields(cfg, fieldsToSet);

end

function cfg = setPacedByTrigger(cfg)

    % reexpress those in terms of repetition time
    if cfg.pacedByTriggers.do

        fieldsToSet.pacedByTriggers.quietMode = true;
        fieldsToSet.pacedByTriggers.nbTriggers = 1;

        fieldsToSet.timing.eventDuration = cfg.mri.repetitionTime / 2 - 0.04; % second

        % Time in nb of volumes between blocs in nb of triggers
        % (remember to consider the nb trigger to wait + 1)
        fieldsToSet.timing.triggerIBI = 4;

        % Time between blocks in secs
        cfg.timing.IBI = 0;

        % Time between events in secs
        cfg.timing.ISI = 0;

        % Number of seconds before the motion stimuli are presented
        cfg.timing.onsetDelay = 0;

        % Number of seconds after the end all the stimuli before ending the run
        cfg.timing.endDelay = 0;

        cfg = setDefaultFields(cfg, fieldsToSet);

    end

end

function cfg = setTarget(cfg)
    % 'fixation_cross' : the fixation cross changes color
    % 'static_repeat' : static dots are in the same position as previous trials

    fieldsToSet.target.maxNbPerBlock = 1;

    if strcmp(cfg.target.type, 'fixation_cross')
        cfg.task.instruction = '1-Detect the RED fixation cross\n \n\n';
        cfg.task.taskDescription = '';
        cfg.fixation.colorTarget = cfg.color.red;

        fieldsToSet.target.duration = 0.1; % In secs

    elseif strcmp(cfg.target.type, 'static_repeat')
        cfg.task.instruction = '1-Detect when the dots are in the same position\n \n\n';
        cfg.task.taskDescription = '';
        cfg.fixation.colorTarget = cfg.fixation.color;

    else
        error('cfg.target.type must be ''fixation_cross'' or ''static_repeat''');

    end

    cfg.bids.MRI.Instructions = cfg.task.instruction;
    cfg.bids.MRI.TaskDescription = cfg.task.taskDescription;

    cfg = setDefaultFields(cfg, fieldsToSet);

end
