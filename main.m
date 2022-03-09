% set your options here and then call visualMotionLocalizer(cfg)
%
% (C) Copyright 2020 CPP visual motion localizer developers

clc;
clear;

%% Run MT+ localizer

cfg.design.localizer = 'MT';

cfg.verbose = 2;

cfg.debug.do = false;
cfg.debug.transpWin = 0;
cfg.debug.smallWin = 0;

cfg.pacedByTriggers.do = true;

cfg.eyeTracker.do = false;

cfg.design.nbRepetitions = 15;

cfg.timing.eventDuration = 0.43; % second

initEnv();

cfg = checkParameters(cfg);

% to view all the options that are set
% unfold(cfg);

% Run
visualMotionLocalizer(cfg);

% clear cfg;

return

%% Run MT/MST localizer

cfg.design.localizer = 'MT_MST';

cfg.verbose = 2;

cfg.debug.do = false;
cfg.debug.transpWin = 0;
cfg.debug.smallWin = 0;

cfg.eyeTracker.do = false;

cfg.design.nbRepetitions = 10;
cfg.design.nbEventsPerBlock = 12;

initEnv();

cfg = checkParameters(cfg);

% to view all the options that are set
% unfold(cfg);

% run
visualMotionLocalizer(cfg);

clear cfg;
