% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = preTrialSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent] = deal(varargin{:});

    % set direction, speed of that event and if it is a target
    thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.direction = cfg.design.directions(iBlock, iEvent);
    thisEvent.speed = cfg.design.speeds(iBlock, iEvent);
    thisEvent.target = cfg.design.fixationTargets(iBlock, iEvent);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;
    
    % To shift the dot matrix 
    thisEvent.dotCenterXPosPix = 0;

    switch thisEvent.trial_type
        case 'fixation_right'
            cfg.aperture.xPosPix = -abs(cfg.aperture.xPosPix);
            
            thisEvent.dotCenterXPosPix = cfg.aperture.xPosPix;

            thisFixation.fixation.xDisplacement = cfg.design.xDisplacementFixation;
            thisFixation = initFixation(thisFixation);

        case 'fixation_left'
            cfg.aperture.xPosPix = +abs(cfg.aperture.xPosPix);
            
            thisEvent.dotCenterXPosPix = cfg.aperture.xPosPix;

            thisFixation.fixation.xDisplacement = -cfg.design.xDisplacementFixation;
            thisFixation = initFixation(thisFixation);

    end

    varargout = {thisEvent, thisFixation, cfg};

end
