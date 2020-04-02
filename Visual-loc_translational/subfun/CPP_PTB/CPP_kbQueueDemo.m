%% KbQueue demo from the CPP lab
% This small script shows how to use the KbQueue wrapper function made for
% the CPP lab.


%% set parameters

ExpParameters.responseKey = {'space', 'm'};

% cfg.responseBox would be the device used by the participant to give his/her response: 
%   like the button box in the scanner or a separate keyboard for a behavioral experiment
%
% cfg.keyboard is the keyboard on which the experimenter will type or press the keys necessary 
%   to start or abort the experiment.
%   The two can be different or the same.

% Using empty vectors should work for linux when to select the "main"
% keyboard. You might have to try some other values for MacOS or Windows
cfg.keyboard = []; 
cfg.responseBox = []; 


%% init

% Keyboard
% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');


% Prevent spilling of keystrokes into console:
ListenChar(-1);


% we ask PTB to tell us which keyboard devices are connected to the computer
[cfg.keyboardNumbers, cfg.keyboardNames] = GetKeyboardIndices;

cfg.keyboardNumbers
cfg.keyboardNames


% Test that the keyboards are correctly configured
testKeyboards(cfg)


%% run demo

fprintf('\nPress space bar or m several times during the next 5 seconds\n\n');

getResponse('init', cfg, ExpParameters, 1);

startSecs = GetSecs();

getResponse('start', cfg, ExpParameters, 1);

WaitSecs(5);

responseEvents = getResponse('check', cfg, ExpParameters, 1);

getResponse('flush', cfg, ExpParameters, 1);

getResponse('stop', cfg, ExpParameters, 1);


% look what keys were pressed and when
for iEvent = 1:size(responseEvents, 1)

    if responseEvents(iEvent,3)
        eventType = 'pressed';
    else
        eventType = 'released';
    end
    
    fprintf('%s was %s at time %.3f seconds\n', ...
        KbName(responseEvents(iEvent,2)), ...
        eventType, ...
        responseEvents(iEvent, 1) - startSecs);

end
