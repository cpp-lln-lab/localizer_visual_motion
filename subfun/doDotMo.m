% (C) Copyright 2018 Mohamed Rezk
% (C) Copyright 2020 CPP visual motion localizer developpers

function [onset, duration, dots] = doDotMo(cfg, thisEvent, thisFixation, dots, iEvent)
    % Draws the stimulation of static/moving in 4 directions dots or static
    %
    % DIRECTIONS
    %  0=Right; 90=Up; 180=Left; 270=down
    %
    % Input:
    %   - cfg: PTB/machine configurations returned by setParameters and initPTB
    %
    % Output:
    %     -
    %
    % The dots are drawn on a square with a width equals to the width of the
    % screen
    % We then draw an aperture on top to hide the certain dots.

    %% Get parameters
    if ~(strcmp(thisEvent.trial_type, 'static') && thisEvent.target == 1) ||  ...
        isempty(dots)
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

        if strcmp(cfg.design.localizer, 'MT_MST') && strcmpi(thisEvent.trial_type, 'static') && ~mod(iEvent, 2)

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

    Screen('DrawingFinished', cfg.screen.win);

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

    duration = vbl - onset;

end
