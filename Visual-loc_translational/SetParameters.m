function [ExpParameters, Cfg] = SetParameters

ExpParameters = struct; % Initialize the parameters variables
Cfg           = struct; % Initialize the general configuration variables

ExpParameters.task = 'VisualLoc';

%% Debug mode settings
Cfg.Debug               = true;  % To test the script out of the scanner, skyp PTB sync
Cfg.TestingSmallScreen  = false; % To test on a part of the screen, change to 1
Cfg.TestingTranspScreen = false;  % To test with trasparent full size screen 
Cfg.Device              = 'PC';  % 'PC': does not care about trigger - 'Scanner'
Cfg.stim_position       = 'PC';  % 'Scanner': means that it removes the lower 1/3 of the screen (the coil hides the lower part of the screen)
Cfg.EyeTracker          = false; % Set to 'true' if you are testing in MRI and want to record ET data

%% MRI settings
Cfg.Device      = 'PC';  % 'PC': does not care about trigger - 'Scanner'
Cfg.triggerKey  = 's';   % Set the letter sent by the trigger to sync stimulation and volume acquisition
Cfg.numTriggers = 4;     % CHECK ON THE MAIN SCRIPT, MADE AN ERROR TO PUT IT HERE BUT IT WILL BE USEFUL ANYWAY

%% Engine parameters
% Monitor parameters
Cfg.monitor_width  	  = 42;  % Monitor Width in cm
Cfg.screen_distance   = 134; % Distance from the screen in cm
Cfg.diameter_aperture = 8;   % Diameter/length of side of aperture in Visual angles

% Monitor parameters for PTB
Cfg.Screen           = max(Screen('Screens')); % Main screen
Cfg.White            = [255 255 255];
Cfg.Black            = [ 0   0   0 ];
Cfg.Grey             = mean([Cfg.Black; Cfg.White]);
Cfg.Background_color = Cfg.Black;
Cfg.textColor        = Cfg.White;
Cfg.TextFont         = 'Courier New';
Cfg.TextSize         = 18;
Cfg.TextStyle        = 1;

%% Experiment Design
ExpParameters.names              = {'static','motion'};
ExpParameters.possibleDirections = [-1 1]; % 1 motion , -1 static
ExpParameters.numBlocks          = size(ExpParameters.possibleDirections,2);
ExpParameters.numRepetitions     = 1;      %AT THE MOMENT IT IS NOT SET IN THE MAIN SCRIPT
ExpParameters.IBI                = 0; %8;      
ExpParameters.ISI                = 0.1;    % Time between events in secs
ExpParameters.onsetDelay         = 5;      % Number of seconds before the motion stimuli are presented
ExpParameters.endDelay           = 5;      % Number of seconds after the end all the stimuli before ending the run


%% Visual Stimulation
ExpParameters.experimentType    = 'Dots';  % Visual modality is in RDKs %NOT USED IN THE MAIN SCIPT
ExpParameters.speedEvent        = 4;       % speed in visual angles
ExpParameters.numEventsPerBlock = 12;      % Number of events per block (should not be changed)
ExpParameters.eventDuration     = .9;
ExpParameters.coh               = 1;       % Coherence Level (0-1)
ExpParameters.maxDotsPerFrame   = 300;     % Maximum number dots per frame (Number must be divisible by 3)
ExpParameters.dotLifeTime       = 0.2;     % Dot life time in seconds
ExpParameters.dontclear         = 0;
ExpParameters.dotSize           = 0.1;     % Dot Size (dot width) in visual angles.
ExpParameters.dotColor          = Cfg.White;

%% Task(s)

% Instruction
ExpParameters.TaskInstruction = '1-Detect the RED fixation cross\n \n\n';

%% Task 1 - Fixation cross
ExpParameters.Task1 = true; % true / false

if ExpParameters.Task1
    % Used Pixels here since it really small and can be adjusted during the experiment
    ExpParameters.fixCrossDimPix               = 10;   % Set the length of the lines (in Pixels) of the fixation cross
    ExpParameters.lineWidthPix                 = 4;    % Set the line width (in Pixels) for our fixation cross
    ExpParameters.maxNumFixationTargetPerBlock = 2;
    ExpParameters.fixationChangeDuration       = 0.15; % In secs
    ExpParameters.xDisplacementFixCross        = 0;   % Manual displacement of the fixation cross
    ExpParameters.yDisplacementFixCross        = 0;   % Manual displacement of the fixation cross
    ExpParameters.fixationCross_color          = Cfg.White;
end

%% Setting some defaults: no need to change things here

if mod(ExpParameters.maxDotsPerFrame,3) ~= 0
    error('Number of dots should be divisible by 3.')
end

if Cfg.Debug
    fprintf('\n\n\n\n')
    fprintf('######################################## \n')
    fprintf('##  DEBUG MODE, NOT THE SCANNER CODE  ## \n')
    fprintf('######################################## \n\n')
end