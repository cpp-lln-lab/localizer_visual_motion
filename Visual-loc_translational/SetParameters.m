function [ExpParameters, Cfg] = SetParameters()

ExpParameters = struct; % Initialize the parameters variables
Cfg           = struct; % Initialize the general configuration variables

%% Debug mode settings
Cfg.TestingSmallScreen = false; % To test on a part of the screen, change to 1
Cfg.device = 'PC';

%% Experiment Design
ExpParameters.numRepetitions  = 1 ; %AT THE MOMENT IT IS NOT SET IN THE MAIN SCRIPT 



