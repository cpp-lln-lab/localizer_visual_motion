function responseTimeWithinEvent = doDotMo(Cfg, ExpParameters, logFile)
% Draws the stimulation of static/moving in 4 directions dots or staticand
%  collects the task responses inside an event (1 direction)
%
% DIRECTIONS
%  0=Right; 90=Up; 180=Left; 270=down
%
%
% Input:
%   - Cfg: PTB/machine configurations returned by SetParameters and initPTB
%   - ExpParameters: parameters returned by SetParameters
%   - logFile: structur that stores the experiment logfile to be saved
%
% Output:
%     % % % could we put this directly in the logFile struct?
%   - responseTimeWithinEvent = subject response for the task
%


%% Get parameters
experimentStart = Cfg.experimentStart;

dontClear  = ExpParameters.dontClear;

coh = ExpParameters.coh;
ndots = ExpParameters.maxDotsPerFrame;
direction = logFile.iEventDirection;

dotSize = ExpParameters.dotSizePpd;
dotLifeTime = ExpParameters.dotLifeTime;
dotColor = ExpParameters.dotColor;
dotSpeed = logFile.iEventSpeed;

eventIsFixationTarget = logFile.iEventIsFixationTarget;
fixationChangeDuration = ExpParameters.fixationChangeDuration;

diamAperture = Cfg.diameterAperture;
diamAperturePpd = Cfg.diameterAperturePpd;

% Check if it is a static or motion block
if direction == -1
    dotSpeed = 0;
    dotLifeTime = ExpParameters.eventDuration;
end


%% initialize variables
responseTimeWithinEvent = [];

% Set an array of dot positions [xposition, yposition]
% These can never be bigger than 1 or lower than 0
xy = rand(ndots, 2);

% Set a N x 2 matrix that gives jumpsize in units on 0 1
%  deg/sec * Ap-unit/deg * sec/jump = unit/jump
dxdy = repmat(dotSpeed*10/(diamAperture*10)*(3/Cfg.monRefresh) ...
    *(cos(pi*direction/180.0)-sin(pi*direction/180.0)), ndots, 1);

% Create a ones vector to update to dotlife time of each dot
dotTime = ones(size(xy, 1), 1);

% Set for how many frames to show the dots
continueShow = floor(ExpParameters.eventDuration/Cfg.ifi);

% Covert the dotLifeTime from seconds to frames
dotLifeTime = ceil(dotLifeTime/Cfg.ifi);


%% Start the dots presentation
movieStartTime = GetSecs();

while continueShow
    
    % Compute new locations, L are the dots that will be moved
    L = rand(ndots,1) < coh;
    
    % Offset the selected dots
    xy(L,:) = xy(L,:) + dxdy(L,:);
    
    % If not 100% coherence
    if sum(~L) > 0
        
        % Get new random locations for the rest
        xy(~L,:) = rand(sum(~L),2);
        
    end
    
    % ??????????????????
    N = sum((xy > 1 | xy < 0 | repmat(dotTime(:,1) > dotLifeTime,1,2))')' ~= 0 ;  %#ok<UDIM>
    
    % Re-allocate the dots to random positions
    if sum(N) > 0
        
        % Re-allocate the chosen dots to random positions
        xy(N,:) = rand(sum(N), 2);
        
        % Find the dots that were re-allocated and change its lifetime to 1
        dotTime(find(N==1),:) = 1;
        
    end
    
    %     % Reallocate to the border of the aperture
    %     if sum(N) > 0
    %         xdir = sin(pi*direction/180.0);
    %         ydir = cos(pi*direction/180.0);
    %         % Flip a weighted coin to see which edge to put the replaced dots
    %         if rand < abs(xdir)/(abs(xdir) + abs(ydir))
    %             xy(find(N==1),:) = [rand(sum(N),1) (xdir > 0)*ones(sum(N),1)];
    %             dotTime(find(N==1),:) = 1;
    %         else
    %             xy(find(N==1),:) = [(ydir < 0)*ones(sum(N),1) rand(sum(N),1)];
    %             dotTime(find(N==1),:) = 1;
    %         end
    %     end
    
    % Add one frame to the dot lifetime to each dot
    dotTime = dotTime + 1;
    
    % Convert to stuff we can actually plot (pix/ApUnit)
    this_x = floor( xy * diamAperturePpd );
    
    % This assumes that zero is at the top left, but we want it to be
    %  in the center, so shift the dots up and left, which just means
    %  adding half of the aperture size to both the x and y direction.
    dotShow = (this_x(:,1:2)-diamAperturePpd/2)';
    
    % NaN out-of-circle dots
    xyDis = dotShow;
    outCircle = sqrt(xyDis(1,:).^2+xyDis(2,:).^2)+dotSize/2 > (diamAperturePpd/2);
    dots2Display = dotShow;
    dots2Display(:,outCircle) = NaN;
    
    
    %% PTB draws the dots stimulation
    
    % Draw the fixation cross
    color = ExpParameters.fixationCrossColor;
    % If this frame shows a target we change the color
    if GetSecs < (movieStartTime+fixationChangeDuration) && eventIsFixationTarget==1
        color = ExpParameters.fixationCrossColorTarget;
    end
    drawFixationCross(Cfg, ExpParameters, color)
    
    % Draw the dots
    Screen('DrawDots', Cfg.win, dots2Display, dotSize, dotColor, Cfg.center, 2);
    
    Screen('DrawingFinished', Cfg.win, dontClear );
    
    Screen('Flip', Cfg.win, 0, dontClear );
    
    
    %% Update loop counter counter

    % Check for end of loop
    continueShow = continueShow - 1;
    
    
    %% Response collection
    
    % % % % % % % % % % % % % % % % %     might need refactoring considering
    % that the scanne provide a letter (keystroke) as trigger as well as the
    % button box. Solution is to have KbCheck looking for a specific input
    % letter     % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    if strcmp(Cfg.device, 'PC')
        
        [KeyIsDown, PressedSecs, ~] = KbCheck(-1);
        
        if KeyIsDown
            
            % Add the response with RT
            responseTimeWithinEvent(end+1)= PressedSecs - experimentStart;
            
        elseif ~KeyIsDown
            
            % Assigne 0 if no response
            responseTimeWithinEvent(end+1)= 0;
            
        end
        
    end
    
    
end

%% Remove duplicate responses coming from the same button press

% % % % %  TO CHECK WHAT IT DOES

for iResponse = length(responseTimeWithinEvent):-1:2
    
    % If preceeding response exists
    if responseTimeWithinEvent(iResponse-1)~=0
        
        % Cancel the current one.
        responseTimeWithinEvent(iResponse)=0 ;
        
    end
    
end

% remove the zeros response times

% % % % % WHY???

responseTimeWithinEvent = responseTimeWithinEvent(responseTimeWithinEvent~=0);


%% Erase last dots

drawFixationCross(Cfg, ExpParameters, ExpParameters.fixationCrossColor)

Screen('DrawingFinished', Cfg.win, dontClear);

Screen('Flip', Cfg.win, 0, dontClear);


end
