% set your options here and then call visualMotionLocalizer(cfg)
%
% (C) Copyright 2020 CPP visual motion localizer developers

clc;
clear;

initEnv();

%% Run MT+ localizer
cfg = cfgMT();

%% Run MT/MST localizer
% cfg = cfgMST();

cfg = checkParameters(cfg);

% to view all the options that are set
% unfold(cfg);

% run
visualMotionLocalizer(cfg);
