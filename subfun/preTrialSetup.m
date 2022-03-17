function varargout = preTrialSetup(varargin)
    %
    % [thisEvent, thisFixation, cfg] = postInitializatinSetup(cfg, iBlock, iEvent)
    %
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    % generic function to prepare some structure before each trial

    [cfg, iBlock, iEvent] = deal(varargin{:});

    % set direction, speed of that event and if it is a target
    thisEvent.trial_type = cfg.design.blockNames{iBlock};
    thisEvent.direction = cfg.design.directions(iBlock, iEvent);
    thisEvent.speedPix = cfg.design.speeds(iBlock, iEvent);
    thisEvent.target = cfg.design.fixationTargets(iBlock, iEvent);

    % If this frame shows a target we change the color of the cross
    thisFixation.fixation = cfg.fixation;
    thisFixation.screen = cfg.screen;

    % ThisEvent.dotCenterXPosPix determines by how much the dot matrix has to be
    % shifted relative to the center of the screen.
    % By default it is centered on screen but for the MT/MST localizer we
    % shift so the center of the radial motion is matched to that of the
    % aperture on the side of the screen.
    %
    % Meanwhile the cross is shifted on the opposite side
    %

    thisEvent.dotCenterXPosPix = 0;

    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

        thisEvent.fixationPosition = cfg.design.blockFixationPosition{iBlock};

        % This is necessary because where the dot aperture is drawn is set in cfg
        % So we "reset" that pixel value from the value in degrees
        cfg.aperture.xPos = cfg.design.xDisplacementAperture;
        cfg.aperture = degToPix('xPos', cfg.aperture, cfg);

        switch thisEvent.fixationPosition

            case 'fixation_right'
                cfg.aperture.xPosPix = -abs(cfg.aperture.xPosPix);
                thisFixation.fixation.xDisplacement = cfg.design.xDisplacementFixation;

            case 'fixation_left'
                cfg.aperture.xPosPix = +abs(cfg.aperture.xPosPix);
                thisFixation.fixation.xDisplacement = -cfg.design.xDisplacementFixation;

            otherwise

                error('WTF');

        end

        if isfield(cfg.fixation, 'xDisplacementPix')
            cfg.aperture.xPosPix = cfg.aperture.xPosPix + cfg.fixation.xDisplacementPix;
        end

        thisEvent.dotCenterXPosPix = cfg.aperture.xPosPix;

        % if isfield(cfg.fixation, 'xDisplacementPix')
        %     thisFixation.fixation.xDisplacement = thisFixation.fixation.xDisplacement + ...
        %                                           cfg.fixation.xDisplacementPix;
        % end

        if isfield(cfg.fixation, 'yDisplacementPix')
        end

        thisFixation.fixation.allCoords;

        thisFixation = initFixation(thisFixation);

    end

    varargout = {thisEvent, thisFixation, cfg};

end
