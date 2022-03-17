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

    % Field of view in DEGREES OF VISUAL ANGLES

    % fixation cross displacement in degrees of visual angles
    % this will also shift the whole FOV
    cfg.fixation.xDisplacement = 0;
    cfg.fixation.yDisplacement = 0;

    % determines position of the fixation cross on the right / left
    % should be a bit less than the: ( width of FOV ) / 2
    cfg.design.xDisplacementFixation = 5;

    % determines position of the dots on the left /
    % should be a bit less than the: ( width of FOV ) / 2
    cfg.design.xDisplacementAperture = 5;

    % determines the width of the dot circle
    cfg.aperture.width = 1;

end
