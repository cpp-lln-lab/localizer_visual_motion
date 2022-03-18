% set your options here and then call visualMotionLocalizer(cfg)
%
% (C) Copyright 2020 CPP visual motion localizer developers

clc;
clear;

initEnv();

cfg.subject.subjectGrp = 'pilot';
cfg.subject.sessionNb = 1;
cfg.subject.askGrpSess = [true false];

cfg.verbose = 1;

cfg.debug.do = true;
cfg.debug.transpWin = true;
cfg.debug.smallWin = false;

cfg.audio.devIdx = 5;

cfg.eyeTracker.do = true;
% in liege
cfg.dot.speed = 7.5;

%% Run MT+ localizer
% cfg = cfgMT(cfg);

%% Run MT/MST localizer
cfg = cfgMST(cfg);

cfg = checkParameters(cfg);

% to view all the options that are set
% unfold(cfg);

% run
visualMotionLocalizer(cfg);
