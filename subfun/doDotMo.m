function [onset, duration, dots] = doDotMo(cfg, thisEvent, thisFixation, dots, iEvent)
    %
    % Wrapper function that present the dot stimulation (static or motion) per event.
    %
    % USAGE::
    %
    %   [onset, duration, dots] = doDotMo(cfg, thisEvent, thisFixation, dots, iEvent)
    %
    % :param cfg: PTB/machine configurations returned. see ``checkParameters``
    % :type cfg: structure
    %
    % :param thisEvent: structure that stores information about the event to present
    % regarding the dots (static or motion, direction, etc.)
    % :type thisEvent:
    %
    % :param thisFixation: structure that stores information about the fixation cross
    % task to present
    % :type thisFixation:
    %
    % :param dots:
    % :type dots:
    %
    % :param iEvent: index of the event of the block at the moment of the presentation
    % :type iEvent:
    %
    %
    % The dots are drawn on a square with a width equals to the width of the
    % screen
    % We then draw an aperture on top to hide the certain dots.
    %
    %
    % (C) Copyright 2018 Mohamed Rezk
    % (C) Copyright 2020 CPP visual motion localizer developers

    %% Get parameters
    if isempty(dots)
        dots = initDots(cfg, thisEvent);
    end

    % Set for how many frames this event will last
    framesLeft = floor(cfg.timing.eventDuration / cfg.screen.ifi);

    %% Start the dots presentation
    vbl = Screen('Flip', cfg.screen.win);
    onset = vbl;

    while framesLeft

        [dots] = updateDots(dots, cfg);

        %% Center the dots

        % We assumed that zero is at the top left, but we want it to be
        %  in the center, so shift the dots up and left, which just means
        %  adding half of the screen width in pixel to both the x and y direction.
        thisEvent.dot.positions = (dots.positions - cfg.dot.matrixWidth / 2)';

        %% make textures

        % If staticReSeed is true, then change the seed of the static dots only
        % for the first event
        if cfg.dot.staticReSeed && ...
           strcmpi(thisEvent.trial_type, 'static') && ...
           iEvent ~= 1

        else

            dotTexture('make', cfg, thisEvent);

        end

        apertureTexture('make', cfg, thisEvent);

        %% draw evetything and flip screen

        dotTexture('draw', cfg, thisEvent);

        apertureTexture('draw', cfg, thisEvent);

        thisFixation.fixation.color = cfg.fixation.color;
        if thisEvent.target(1) && vbl < (onset + cfg.target.duration)
            thisFixation.fixation.color = cfg.fixation.colorTarget;
        end
        drawFixation(thisFixation);

        Screen('DrawingFinished', cfg.screen.win);

        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

        %% Update counters

        % Check for end of loop
        framesLeft = framesLeft - 1;

    end

    %% Erase last dots

    drawFixation(thisFixation);

    if cfg.dot.staticReSeed && ...
            strcmpi(thisEvent.trial_type, 'static') && ...
            iEvent ~= cfg.design.nbEventsPerBlock

        dotTexture('draw', cfg, thisEvent);

        apertureTexture('draw', cfg, thisEvent);

    else

        Screen('DrawingFinished', cfg.screen.win);

        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

    end

    duration = vbl - onset;

end
