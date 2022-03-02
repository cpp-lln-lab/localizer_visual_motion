% set your options here and then call visualMotionLocalizer(cfg)
%
% (C) Copyright 2020 CPP visual motion localizer developers

cfg.design.localizer = 'MT';

initEnv();

cfg = checkParameters(cfg);

%% To view all the options that are set
%
% unfold(cfg);

%% Run
%

visualMotionLocalizer(cfg);
