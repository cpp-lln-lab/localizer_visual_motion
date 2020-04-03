%% Demo showing how to use the getResponse function

% This small script shows how to use the getReponse function 
%  (a wrapper around the KbQueue function from PTB)

%% set parameters

% cfg.responseBox would be the device used by the participant to give his/her response:
%  like the button box in the scanner or a separate keyboard for a behavioral experiment
%
% cfg.keyboard is the keyboard on which the experimenter will type or press the keys necessary
%  to start or abort the experiment.
%  The two can be different or the same.

% Using empty vectors should work for linux when to select the "main"
%  keyboard. You might have to try some other values for MacOS or Windows
cfg.keyboard = [];
cfg.responseBox = [];

% We set which keys are "valid", any keys other than those will be ignored
ExpParameters.responseKey = {};


%% init

% Keyboard
%  Make sure keyboard mapping is the same on all supported operating systems
%  Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');


% Prevent spilling of keystrokes into console
ListenChar(-1);


% we ask PTB to tell us which keyboard devices are connected to the computer
[cfg.keyboardNumbers, cfg.keyboardNames] = GetKeyboardIndices;

cfg.keyboardNumbers
cfg.keyboardNames


% Test that the keyboards are correctly configured
testKeyboards(cfg)


%% Run demo

fprintf('\nPress space bar or m several times during the next 5 seconds\n\n');

% Create the keyboard queue to collect responses.
getResponse('init', cfg, ExpParameters, 1);

% Start collecting responses for 5 seconds
%  Each new key press is added to the queue of events recorded by KbQueue
startSecs = GetSecs();
getResponse('start', cfg, ExpParameters, 1);



% Here we wait for 5 seconds but are still collecting responses.
%  So you could still be doing something else (presenting audio and visual stim) and
%  still collect responses.
WaitSecs(5);




% Check what keys were pressed (all of them)
responseEvents = getResponse('check', cfg, ExpParameters, 1);

% This can be used to flush the queue: empty all events that are still present in the queue
getResponse('flush', cfg, ExpParameters, 1);

% If you wan to stop listening to key presses.
getResponse('stop', cfg, ExpParameters, 1);



% Give me my keyboard back... Pretty please.
ListenChar();


%% Now we look what keys were pressed and when
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
