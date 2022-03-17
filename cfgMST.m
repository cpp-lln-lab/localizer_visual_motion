function cfg = cfgMST(cfg)
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT_MST';

    cfg.design.nbRepetitions = 10;

    cfg.design.nbEventsPerBlock = 10;

    % in Liege is 0.6
    % on macs is 0.3
    cfg.timing.eventDuration = 0.6; % 0.6 seconds

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
    %
    %
    % Field of view in DEGREES OF VISUAL ANGLES:
    %  top left: 8.0 1.0
    %  bottom right: 11.0 3.0
    %
    % Field of view in DEGREES OF VISUAL ANGLES:
    %  width: 1.8
    %  height: 3.3
    %
    % fixation cross displacement in degrees of visual angles
    % this will also shift the whole FOV
    % cfg.fixation.xDisplacement = 0;
    cfg.fixation.yDisplacement = 1;

    cfg.design.xDisplacementFixation = 2;

    cfg.aperture.width = 4;
    cfg.design.xDisplacementAperture = 4;

end
