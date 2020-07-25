function [cfg, expParameters] = setParameters

    % Initialize the parameters and general configuration variables
    expParameters = struct();
    cfg = struct();

    expParameters.task = 'visualLocalizer';

    % by default the data will be stored in an output folder created where the
    % setParamters.m file is
    % change that if you want the data to be saved somewhere else
    expParameters.outputDir = fullfile( ...
        fileparts(mfilename('fullpath')), '..', ...
        'output');

    %% Debug mode settings
    cfg.debug = true; % To test the script out of the scanner, skip PTB sync
    cfg.testingSmallScreen = false; % To test on a part of the screen, change to 1
    cfg.testingTranspScreen = true; % To test with trasparent full size screen

    expParameters.verbose = true;

    %% Engine parameters

    cfg.testingDevice = 'pc';
    cfg.eyeTracker = false;

    [cfg, expParameters] = setMonitor(cfg, expParameters);

    % Keyboards
    [cfg, expParameters] = setKeyboards(cfg, expParameters);

    % MRI settings
    [cfg, expParameters] = setMRI(cfg, expParameters);

    %% Experiment Design
    expParameters.names = {'static', 'motion'};
    expParameters.possibleDirections = [-1 1]; % 1 motion , -1 static
    expParameters.numBlocks = size(expParameters.possibleDirections, 2);
    expParameters.numRepetitions = 1; % AT THE MOMENT IT IS NOT SET IN THE MAIN SCRIPT
    expParameters.IBI = 0; % 8;
    % Time between events in secs
    expParameters.ISI = 0.1;
    % Number of seconds before the motion stimuli are presented
    expParameters.onsetDelay = 5;
    % Number of seconds after the end all the stimuli before ending the run
    expParameters.endDelay = 1;

    %% Visual Stimulation
    % speed in visual angles
    expParameters.speedEvent = 8;
    % Number of events per block (should not be changed)
    expParameters.numEventsPerBlock = 12;
    expParameters.eventDuration = 1;
    % Coherence Level (0-1)
    expParameters.coh = 1;
    % Maximum number dots per frame
    expParameters.maxDotsPerFrame = 300;
    % Dot life time in seconds
    expParameters.dotLifeTime = 1;
    % Dot Size (dot width) in visual angles.
    expParameters.dotSize = 0.1;
    expParameters.dotColor = cfg.white;
    expParameters.dontClear = 0;
    % Diameter/length of side of aperture in Visual angles
    cfg.diameterAperture = 8;

    %% Task(s)

    % Instruction
    expParameters.taskInstruction = '1-Detect the RED fixation cross\n \n\n';

    % Fixation cross (in pixels)
    % Set the length of the lines of the fixation cross
    expParameters.fixCrossDimPix = 10;
    % Set the line width for our fixation cross
    expParameters.lineWidthPix = 4;
    expParameters.maxNumFixationTargetPerBlock = 2;
    expParameters.targetDuration = 0.15; % In secs

    expParameters.xDisplacementFixCross = 0; % Manual displacement of the fixation cross
    expParameters.yDisplacementFixCross = 0; % Manual displacement of the fixation cross
    expParameters.fixationCrossColor = cfg.white;
    expParameters.fixationCrossColorTarget = cfg.red;
end

function [cfg, expParameters] = setKeyboards(cfg, expParameters)
    cfg.keyboard.escapeKey = 'ESCAPE';
    expParameters.responseKey = {'space'};

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.keyboard.keyboard = [];
        cfg.keyboard.responseBox = [];
    end
end

function [cfg, expParameters] = setMRI(cfg, expParameters)
    % letter sent by the trigger to sync stimulation and volume acquisition
    cfg.triggerKey = 't';
    cfg.numTriggers = 4;

    expParameters.bids.MRI.RepetitionTime = 2;

end

function [cfg, expParameters] = setMonitor(cfg, expParameters)

    % Monitor parameters for PTB
    cfg.white = [255 255 255];
    cfg.black = [0 0 0];
    cfg.red = [255 0 0];
    cfg.grey = mean([cfg.black; cfg.white]);
    cfg.backgroundColor = cfg.black;
    cfg.textColor = cfg.white;

    % Monitor parameters
    cfg.monitorWidth = 42; % in cm
    cfg.screenDistance = 134; % distance from the screen in cm

    if strcmpi(cfg.testingDevice, 'mri')
        cfg.monitorWidth = 42;
        cfg.screenDistance = 134;
    end
end
