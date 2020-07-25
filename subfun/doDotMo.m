function [onset, duration] = doDotMo(cfg, expParameters, thisEvent)
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
dontClear  = expParameters.dontClear;

direction = thisEvent.direction(1);
isTarget = thisEvent.target(1);
speed = thisEvent.speed(1);

coh = expParameters.coh;
ndots = expParameters.maxDotsPerFrame;
dotSizePix = expParameters.dotSizePix;
dotLifeTime = expParameters.dotLifeTime;
dotColor = expParameters.dotColor;

targetDuration = expParameters.targetDuration;

% thisEvent = deg2Pix('speed', thisEvent, cfg);
% dotSpeedPix = logFile.iEventSpeedPix;

diamAperturePix = cfg.diameterAperturePix;
diamAperture = cfg.diameterAperture;

% Check if it is a static or motion block
if direction == -1

    %dotSpeedPix = 0;

    speed = 0;

    dotLifeTime = expParameters.eventDuration;
end


%% initialize variables

% Set an array of dot positions [xposition, yposition]
% These can never be bigger than 1 or lower than 0
% [0,0] is the top / left of the square that contains the square aperture
% [1,1] is the bottom / right of the square that contains the square aperture
xy = rand(ndots, 2);

% Set a N x 2 matrix that gives jump size in pixels
%  pix/sec * sec/frame = pix / frame
dxdy = repmat(...
    speed * 10/(diamAperture*10) * (3/cfg.monRefresh) ...
    * [cos(pi*direction/180.0) -sin(pi*direction/180.0)], ndots,1);

% dxdy = repmat(...
%     dotSpeedPix / Cfg.ifi ...
%     * (cos(pi*direction/180) - sin(pi*direction/180)), ...
%     ndots, 1);

% Create a ones vector to update to dotlife time of each dot
dotTime = ones(size(xy, 1), 1);

% Set for how many frames to show the dots
continueShow = floor(expParameters.eventDuration/cfg.ifi);

% Covert the dotLifeTime from seconds to frames
dotLifeTime = ceil(dotLifeTime/cfg.ifi);


%% Start the dots presentation
vbl = Screen('Flip', cfg.win, 0, dontClear );
onset = vbl;

while continueShow

    % L are the dots that will be moved
    L = rand(ndots,1) < coh;

    % Move the selected dots
    xy(L,:) = xy(L,:) + dxdy(L,:);

    % If not 100% coherence, we get new random locations for the other dots
    if sum(~L) > 0
        xy(~L,:) = rand(sum(~L),2);
    end

    % Create a logical vector to detect any dot that has:
    % - an xy position inferior to 0
    % - an xy position superior to 1
    % - has exceeded its liftime
    N = any([xy > 1, xy < 0, dotTime > dotLifeTime], 2) ;

    % If there is any such dot we relocate it to a new random position
    % and change its lifetime to 1
    if any(N)
        xy(N,:) = rand(sum(N), 2);
        dotTime(N, 1) = 1;
    end

    % Convert the dot position to pixels
    xy_pix = floor( xy * diamAperturePix );

    % This assumes that zero is at the top left, but we want it to be
    %  in the center, so shift the dots up and left, which just means
    %  adding half of the aperture size to both the x and y direction.
    xy_pix = (xy_pix - diamAperturePix/2)';

    % NaN out-of-circle dots
    % We use Pythagore's theorem to figure out which dots are out of the
    % circle
    outCircle = sqrt(xy_pix(1,:).^2 + xy_pix(2,:).^2) + dotSizePix/2 > (diamAperturePix / 2);
    xy_pix(:, outCircle) = NaN;


    %% PTB draws the dots stimulation

    % Draw the fixation cross
    color = expParameters.fixationCrossColor;
    % If this frame shows a target we change the color
    if GetSecs < (onset+targetDuration) && isTarget==1
        color = expParameters.fixationCrossColorTarget;
    end
    drawFixationCross(cfg, expParameters, color)

    % Draw the dots
    Screen('DrawDots', cfg.win, xy_pix, dotSizePix, dotColor, cfg.center, 2);

    Screen('DrawingFinished', cfg.win, dontClear );

    vbl = Screen('Flip', cfg.win, vbl+cfg.ifi, dontClear );


    %% Update counters

    % Check for end of loop
    continueShow = continueShow - 1;

    % Add one frame to the dot lifetime to each dot
    dotTime = dotTime + 1;

end


%% Erase last dots

drawFixationCross(cfg, expParameters, expParameters.fixationCrossColor)

Screen('DrawingFinished', cfg.win, dontClear);

vbl = Screen('Flip', cfg.win, vbl+cfg.ifi, dontClear);

duration = vbl - onset;


end
