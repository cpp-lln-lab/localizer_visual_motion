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
    cfg.stimPosition = 'pc'; % 'Scanner': means that it removes the lower 1/3 of the screen (the coil hides the lower part of the screen)

    expParameters.verbose = true;

    %% MRI settings
    cfg.testingDevice = 'pc'; % 'PC': does not care about trigger - otherwise use 'mri'
    cfg.triggerKey = 't'; % Set the letter sent by the trigger to sync stimulation and volume acquisition
    cfg.numTriggers = 4;
    cfg.eyeTracker = false; % Set to 'true' if you are testing in MRI and want to record ET data

    expParameters.bids.MRI.RepetitionTime = 2;

    %% Engine parameters

    % Monitor parameters
    cfg.monitorWidth     = 42; % Monitor Width in cm
    cfg.screenDistance = 134; % Distance from the screen in cm
    cfg.diameterAperture = 8; % Diameter/length of side of aperture in Visual angles

    % Monitor parameters for PTB
    cfg.white = [255 255 255];
    cfg.black = [0 0 0];
    cfg.red = [255 0 0];
    cfg.grey = mean([cfg.black; cfg.white]);
    cfg.backgroundColor = cfg.black;
    cfg.textColor = cfg.white;

    %% Keyboards

    cfg.keyboard.escapeKey = 'ESCAPE';
    expParameters.responseKey = {'space'};

    if strcmpi(cfg.testingDevice, 'scanner')

        cfg.keyboard.keyboard = [];
        cfg.keyboard.responseBox = [];

    end

    %% Experiment Design
    expParameters.names = {'static', 'motion'};
    expParameters.possibleDirections = [-1 1]; % 1 motion , -1 static
    expParameters.numBlocks = size(expParameters.possibleDirections, 2);
    expParameters.numRepetitions = 1; % AT THE MOMENT IT IS NOT SET IN THE MAIN SCRIPT
    expParameters.IBI = 0; % 8;
    expParameters.ISI = 0.1; % Time between events in secs
    expParameters.onsetDelay = 5; % Number of seconds before the motion stimuli are presented
    expParameters.endDelay = 1; % Number of seconds after the end all the stimuli before ending the run

    %% Visual Stimulation
    expParameters.experimentType = 'Dots'; % Visual modality is in RDKs %NOT USED IN THE MAIN SCIPT
    expParameters.speedEvent = 8; % speed in visual angles
    expParameters.numEventsPerBlock = 12; % Number of events per block (should not be changed)
    expParameters.eventDuration = 1;
    expParameters.coh = 1; % Coherence Level (0-1)
    expParameters.maxDotsPerFrame = 300; % Maximum number dots per frame (Number must be divisible by 3)
    expParameters.dotLifeTime = 1; % Dot life time in seconds
    expParameters.dontClear = 0;
    expParameters.dotSize = 0.1; % Dot Size (dot width) in visual angles.
    expParameters.dotColor = cfg.white;

    %% Task(s)

    % Instruction
    expParameters.taskInstruction = '1-Detect the RED fixation cross\n \n\n';

    % Fixation cross

    % Used Pixels here since it really small and can be adjusted during the experiment
    expParameters.fixCrossDimPix = 10; % Set the length of the lines (in Pixels) of the fixation cross
    expParameters.lineWidthPix = 4; % Set the line width (in Pixels) for our fixation cross
    expParameters.maxNumFixationTargetPerBlock = 2;
    expParameters.targetDuration = 0.15; % In secs

    expParameters.xDisplacementFixCross = 0; % Manual displacement of the fixation cross
    expParameters.yDisplacementFixCross = 0; % Manual displacement of the fixation cross
    expParameters.fixationCrossColor = cfg.white;
    expParameters.fixationCrossColorTarget = cfg.red;
end
