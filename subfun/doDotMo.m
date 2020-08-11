function [onset, duration] = doDotMo(cfg, thisEvent)
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

    dots = initDots(cfg, thisEvent);

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
        dotTexture('make', cfg, thisEvent);

        apertureTexture('make', cfg, thisEvent);

        %% draw evetything and flip screen

        dotTexture('draw', cfg, thisEvent);

        apertureTexture('draw', cfg, thisEvent);

        % If this frame shows a target we change the color of the cross
        thisFixation.fixation = cfg.fixation;
        thisFixation.screen = cfg.screen;
        if thisEvent.target(1) && GetSecs < (onset + cfg.target.duration)
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

    drawFixation(cfg);

    Screen('DrawingFinished', cfg.screen.win);

    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);

    duration = vbl - onset;

end
