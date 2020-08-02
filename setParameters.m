function [cfg] = setParameters()

    % Initialize the parameters and general configuration variables
    cfg = struct();

    % by default the data will be stored in an output folder created where the
    % setParamters.m file is
    % change that if you want the data to be saved somewhere else
    cfg.dir.output = fullfile( ...
        fileparts(mfilename('fullpath')), '..', ...
        'output');

    %% Debug mode settings
    cfg.debug.do = true; % To test the script out of the scanner, skip PTB sync
    cfg.debug.smallWin = false; % To test on a part of the screen, change to 1
    cfg.debug.transpWin = true; % To test with trasparent full size screen

    cfg.verbose = false;

    %% Engine parameters

    cfg.testingDevice = 'pc';
    cfg.eyeTracker.do = false;
    cfg.audio.do = false;

    cfg = setMonitor(cfg, cfg);

    % Keyboards
    cfg = setKeyboards(cfg, cfg);

    % MRI settings
    cfg = setMRI(cfg, cfg);

    %% Experiment Design
    cfg.names = {'static', 'motion'};
    cfg.possibleDirections = [-1 1]; % 1 motion , -1 static
    cfg.numBlocks = size(cfg.possibleDirections, 2);
    cfg.numRepetitions = 1; % AT THE MOMENT IT IS NOT SET IN THE MAIN SCRIPT
    cfg.IBI = 0; % 8;
    % Time between events in secs
    cfg.ISI = 0.1;
    % Number of seconds before the motion stimuli are presented
    cfg.onsetDelay = 1;
    % Number of seconds after the end all the stimuli before ending the run
    cfg.endDelay = 1;

    %% Visual Stimulation

    % Number of events per block (should not be changed)
    cfg.numEventsPerBlock = 12;
    cfg.eventDuration = 1; % second

    % speed in visual angles
    cfg.dot.speed = 1;
    % Coherence Level (0-1)
    cfg.dot.coh = .7;
    % nb dots per visual angle square.
    cfg.dot.density = 5; 
    
    % Dot life time in seconds
    cfg.dot.lifeTime = 1;
    % Dot Size (dot width) in visual angles.
    cfg.dot.size = 0.1;
    cfg.dot.color = cfg.color.white;

    % Diameter/length of side of aperture in Visual angles
    cfg.aperture.type = 'circle';
    cfg.aperture.width = []; % if left empty it will take the screen height

    %% Task(s)

    cfg.task.name = 'visual localizer';

    % Instruction
    cfg.task.instruction = '1-Detect the RED fixation cross\n \n\n';

    % Fixation cross (in pixels)
    cfg.fixation.type = 'cross';
    cfg.fixation.colorTarget = cfg.color.red;
    cfg.fixation.color = cfg.color.white;
    cfg.fixation.width = .15;
    cfg.fixation.lineWidthPix = 2;

    cfg.target.maxNbPerBlock = 2;
    cfg.target.duration = 0.15; % In secs

    cfg.extraColumns = {'direction', 'speed', 'target', 'event', 'block'};
end

function cfg = setKeyboards(cfg)
    cfg.keyboard.escapeKey = 'ESCAPE';
    cfg.keyboard.responseKey = {'space'};
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
    cfg.mri.triggerNb = 4;

    cfg.mri.repetitionTime = 2;

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
    cfg.screen.monitorWidth = 42; % in cm
    cfg.screen.monitorDistance = 134; % distance from the screen in cm

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.screen.monitorWidth = 42;
        cfg.screen.monitorDistance = 134;
    end
end
