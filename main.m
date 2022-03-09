% set your options here and then call visualMotionLocalizer(cfg)
%
% (C) Copyright 2020 CPP visual motion localizer developers

clear all
clc

%% Run MT+ localizer

cfg.design.localizer = 'MT';
cfg.debug.do = true;
cfg.pacedByTriggers.do = true;
cfg.eyeTracker.do = false;

cfg.design.nbRepetitions = 15;
cfg.timing.eventDuration = 0.43; % second

initEnv();

cfg = checkParameters(cfg);

% to view all the options that are set
% unfold(cfg);

% run
visualMotionLocalizer(cfg);

clear cfg

% Run MT/MST localizer

cfg.design.localizer = 'MT_MST';
cfg.debug.do = true;
cfg.eyeTracker.do = false;

cfg.design.nbRepetitions = 10;
cfg.design.nbEventsPerBlock = 12;

initEnv();

cfg = checkParameters(cfg);

% to view all the options that are set
% unfold(cfg);

% run
visualMotionLocalizer(cfg);

clear cfg