%% init

% Keyboard
% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');

[cfg.keyboardNumbers, cfg.keyboardNames] = GetKeyboardIndices;

cfg.keyboardNumbers
cfg.keyboardNames

% Computer keyboard to quit if it is necessary
cfg.keyboard = []; 

% For key presses for the subject
cfg.responseBox = []; 

% Test that the keyboards are correctly configured
testKeyboards(cfg)


%% set parameters

ExpParameters.responseKey = {'space', 'm'};


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
