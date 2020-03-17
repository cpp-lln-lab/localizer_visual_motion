function [ExpParameters, Cfg] = SetParameters()

ExpParameters = struct; % Initialize the parameters variables
Cfg           = struct; % Initialize the general configuration variables

%% Debug mode settings
Cfg.TestingSmallScreen = false; % To test on a part of the screen, change to 1
Cfg.Debug              = true;  % To test the script out of the scanner
Cfg.stim_position      = 'PC';  % 'Scanner': means that it removes the lower 1/3 of the screen (the coil hides the lower part of the screen)

%% MRI settings
Cfg.Device             = 'PC';  % 'PC': does not care about trigger - 'Scanner'
Cfg.triggerKey         = 's';   %set the letter sent by the trigger to sync stimulation and volume acquisition
Cfg.numTriggers        = 4;   % CHECK ON THE MAIN SCRIPT, MADE AN ERROR TO PUT IT HERE BUT IT WILL BE USEFUL ANYWAY


%% Engine parameters
% Monitor parameters
Cfg.monitor_width  	  = 42;  % Monitor Width in cm
Cfg.screen_distance   = 134; % Distance from the screen in cm

% Monitor parameters for PTB
Cfg.Screen            = max(Screen('Screens')); % Main screen
Cfg.White             = [255 255 255];
Cfg.Black             = [ 0   0   0 ];
Cfg.Grey              = ceil(mean([Cfg.Black; Cfg.White]));
Cfg.Background_color  = Cfg.Black;
Cfg.textColor         = Cfg.White;
Cfg.TextFont          = 'Courier New';
Cfg.TextSize          = 20;
Cfg.TextStyle         = 1;

%% Experiment Design
ExpParameters.possibleConditions  = {'static', 'motion'};
ExpParameters.onsetDelay = 2;                               %%% IN THE MAIN EXP IS 5   % Seconds before the motion stimuli are presented, the scans will be discarded until the magnetic field is homogenous                                                            
ExpParameters.blockDur   = 16;                            % Block duration %%% [should be a multiple of osc (below)]                                                                               
ExpParameters.nrCycles   = ExpParameters.blockDur/2 ;     % Number of cycles per block, where 1 Cycle = one inward and outward motion together
ExpParameters.nrTrials   = 7;                             % Number of trials, where 1 trial = 1 block of all conditions (static and motion)
ExpParameters.IBI        = 8;                               %%% BETWEEN CONDITION?  % Inter-block duration in seconds (time between blocks) 

%% Visual Stimulation
ExpParameters.dot_speed   = 4;                                                               % dot speed (deg/sec)
ExpParameters.ndots       = 120;                                                             % number of dots
ExpParameters.min_d       = 0.1;                                                             % minumum radius of  annulus (degrees)
ExpParameters.max_d       = 4;  %Cfg.winRect(3)/(3*2)                                           % maximum radius of  annulus (degrees)
ExpParameters.dot_w       = 0.1;                                                             % width of dot (deg)
ExpParameters.fix_r       = 0.03;                                                            % radius of fixation point (deg)
ExpParameters.f_kill      = 0.05;                                                            % fraction of dots to kill each frame (limited lifetime)
ExpParameters.differentcolors = 0;                                                           % Use a different color for each point if == 1. Use common color white if == 0.
ExpParameters.differentsizes  = 0;                                                           % Use different sizes for each point if >= 1. Use one common size if == 0.
ExpParameters.waitframes = 1;                                                                % Show new dot-images at each waitframes'th monitor refresh.
ExpParameters.reallocate_staticDots = 0 ;                                                    % 0 = static dots will stay in the same position , 1 = static dots will be % reallocated in each cycle (2 seconds)   
%% Task Instructions

ExpParameters.TaskInstruction = 'Press for RED fixation circle';

%% Task 1 - Fixation cross
ExpParameters.Task1 = true; % true / false

if ExpParameters.Task1
    ExpParameters.range_targets = [2 4]; % range of number of targets in each block (from 2 to 5 targets in each block)
end

