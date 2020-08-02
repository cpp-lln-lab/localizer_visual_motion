function [onset, duration] = doDotMo(cfg, thisEvent)
    % Draws the stimulation of static/moving in 4 directions dots or static
    %
    % DIRECTIONS
    %  0=Right; 90=Up; 180=Left; 270=down
    %
    % Input:
    %   - cfg: PTB/machine configurations returned by setParameters and initPTB
    %   - expParameters: parameters returned by setParameters
    %   - logFile: structure that stores the experiment logfile to be saved
    %
    % Output:
    %     -
    %
    % The dots are drawn on a square that contains the round aperture, then any
    % dots outside of the aperture is turned into a NaN so effectively the
    % actual number of dots on the screen at any given time is not the one that you input but a
    % smaller number (nDots / Area of aperture) on average.
    
    %% Get parameters
    direction = thisEvent.direction(1);
    isTarget = thisEvent.target(1);
    
    
    dotLifeTime = cfg.dot.lifeTime;
    
    targetDuration = cfg.target.duration;
    
    % thisEvent = deg2Pix('speed', thisEvent, cfg);
    % dotSpeedPix = logFile.iEventSpeedPix;
    
    coh = cfg.dot.coh;
    speed = thisEvent.speed(1);
    % Check if it is a static or motion block
    if direction == -1
        
        speed = 0;
        coh = 1;
        
        dotLifeTime = cfg.eventDuration;
    end
    
    %% initialize variables
    
    % Set an array of dot positions [xposition, yposition]
    % These can never be bigger than 1 or lower than 0
    % [0,0] is the top / left of the square
    % [1,1] is the bottom / right of the square
    dotPositions = rand(cfg.dot.number, 2);
    
    % Set a N x 2 matrix that gives jump size in pixels
    %  pix/sec * sec/frame = pix / frame
    dxdy = repmat( ...
        speed * 10 / (cfg.aperture.width * 10) * (3 / cfg.screen.monitorRefresh) * ...
        [cos(pi * direction / 180.0) -sin(pi * direction / 180.0)], cfg.dot.number, 1);
    
    % dxdy = repmat(...
    %     dotSpeedPix / Cfg.ifi ...
    %     * (cos(pi*direction/180) - sin(pi*direction/180)), ...
    %     ndots, 1);
    
    % Create a ones vector to update to dotlife time of each dot
    dotTime = ones(size(dotPositions, 1), 1);
    
    % Covert the dotLifeTime from seconds to frames
    dotLifeTime = ceil(dotLifeTime / cfg.screen.ifi);
    
    % Set for how many frames this event will last
    framesLeft = floor(cfg.eventDuration / cfg.screen.ifi);

    %% Start the dots presentation
    vbl = Screen('Flip', cfg.screen.win);
    onset = vbl;
    
    while framesLeft
        
        % L are the dots that will be moved
        L = rand(cfg.dot.number, 1) < coh;
        
        % Move the selected dots
        dotPositions(L, :) = dotPositions(L, :) + dxdy(L, :);
        
        % If not 100% coherence, we get new random locations for the other dots
        if sum(~L) > 0
            dotPositions(~L, :) = rand(sum(~L), 2);
        end
        
        % Create a logical vector to detect any dot that has:
        % - an xy position inferior to 0
        % - an xy position superior to 1
        % - has exceeded its liftime
        N = any([dotPositions > 1, dotPositions < 0, dotTime > dotLifeTime], 2) ;
        
        % If there is any such dot we relocate it to a new random position
        % and change its lifetime to 1
        if any(N)
            dotPositions(N, :) = rand(sum(N), 2);
            dotTime(N, 1) = 1;
        end
        
        %% Convert the dot position to pixels
        % We expand that square so that its side is equal to the whole
        % screen width.
        % With no aperture the whole screen is filled with dots.
        dotPositionsPix = floor(dotPositions * cfg.screen.winRect(3));
        
        % This assumes that zero is at the top left, but we want it to be
        %  in the center, so shift the dots up and left, which just means
        %  adding half of the aperture size to both the x and y direction.
        dotPositionsPix = (dotPositionsPix - cfg.screen.winRect(3) / 2)';
        
        thisEvent.dot.positions = dotPositionsPix;
        
        %% make textures
        dotTexture('make', cfg, thisEvent);
        
        apertureTexture('make', cfg, thisEvent);
        
        %% draw evetything and flip screen
        
        dotTexture('draw', cfg, thisEvent);
        
        apertureTexture('draw', cfg, thisEvent);
        
        % If this frame shows a target we change the color
        thisFixation.fixation = cfg.fixation;
        thisFixation.screen = cfg.screen;
        if GetSecs < (onset + targetDuration) && isTarget == 1
            thisFixation.fixation.color = cfg.fixation.colorTarget;
        end
        drawFixation(thisFixation);
        
        Screen('DrawingFinished', cfg.screen.win);
        
        vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);
        
        %% Update counters
        
        % Check for end of loop
        framesLeft = framesLeft - 1;
        
        % Add one frame to the dot lifetime to each dot
        dotTime = dotTime + 1;
        
    end
    
    %% Erase last dots
    
    drawFixation(cfg);
    
    Screen('DrawingFinished', cfg.screen.win);
    
    vbl = Screen('Flip', cfg.screen.win, vbl + cfg.screen.ifi);
    
    duration = vbl - onset;
    
end

