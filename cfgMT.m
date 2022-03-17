function cfg = cfgMT(cfg)
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT';

    cfg.pacedByTriggers.do = false;

    cfg.mri.triggerNb = 0;

    cfg.design.nbRepetitions = 15;

    cfg.timing.eventDuration = 0.43; % .86 second

    %% variable FOV info
    % in case the field of view is not properly centered or obstructed
    %
    % see https://github.com/cpp-lln-lab/estimate_visual_FOV.git
    %
    % set up configuration: ensure that the following fields are the same
    % as when you ran the estimate_visual_FOV script
    %
    % cfg.testingDevice
    % cfg.screen.monitorDistance
    % cfg.screen.monitorWidth

    % fixation cross displacement in degrees of visual angles
    %
    % cfg.fixation.xDisplacement = FIXME;
    % cfg.fixation.yDisplacement = FIXME;

end
