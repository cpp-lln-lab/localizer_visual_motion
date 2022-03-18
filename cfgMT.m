function cfg = cfgMT(cfg)
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT';

    cfg.pacedByTriggers.do = false;

    cfg.timing.triggerIBI = 4;

    cfg.mri.triggerNb = 0;

    cfg.design.nbRepetitions = 15;

    cfg.design.nbEventsPerBlock = 12;

    % in Liege is 0.79 (tsry less)
    % in mcas is 0.43
    cfg.timing.eventDuration = 0.79; % .86 second

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
    % this will also shift the whole FOV relative to the center of the screen
    % Note: negative values will move things to the left and up.

    cfg.fixation.xDisplacement = 0;
    cfg.fixation.yDisplacement = 0;

end
