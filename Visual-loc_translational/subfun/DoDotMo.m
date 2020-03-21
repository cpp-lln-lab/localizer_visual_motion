function responseTimeWithinEvent = DoDotMo(Cfg, ExpParameters, logFile)
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

% Get the parameters
experimentStart = Cfg.experimentStart;

dontClear  = ExpParameters.dontClear;

coh = ExpParameters.coh;
maxDotsPerFrame = ExpParameters.maxDotsPerFrame;
direction = logFile.iEventDirection;

dotSize = ExpParameters.dotSizePpd;
dotLifeTime = ExpParameters.dotLifeTime;
dotColor = ExpParameters.dotColor;
dotSpeed = logFile.iEventSpeed;

eventIsFixationTarget = logFile.iEventIsFixationTarget;
fixationChangeDuration = ExpParameters.fixationChangeDuration;

% Check if it is a static or motion block
if direction == -1
    
    dotSpeed = 0;
    
    dotLifeTime = ExpParameters.eventDuration;
    
end

responseTimeWithinEvent = [];

% Claculate the number of dots per event ????????????
ndots = min(maxDotsPerFrame, ceil(Cfg.diameterAperturePpd.*Cfg.diameterAperturePpd/Cfg.monRefresh));

% Set a N x 2 matrix that gives jumpsize in units on 0 1
%  deg/sec * Ap-unit/deg * sec/jump = unit/jump
dxdy = repmat(dotSpeed*10/(Cfg.diameterAperture*10)*(3/Cfg.monRefresh) ...
    *(cos(pi*direction/180.0)-sin(pi*direction/180.0)), ndots, 1);

% Set loop indices in a array of dot positions raw [xposition, yposition]
ss = rand(ndots*3, 2);

% Divide dots into three sets
Ls = cumsum(ones(ndots,3)) + repmat([0 ndots ndots*2], ndots, 1);

% Set for how many frames to show the dots
continueShow = floor(ExpParameters.eventDuration/Cfg.ifi);

% Covert the dotLifeTime from seconds to frames
dotLifeTime = ceil(dotLifeTime/Cfg.ifi);

% Create a ones vector to update to dotlife time of each dot
dotTime = ones(size(Ls,1),2);

%% Start the dots presentation
movieStartTime= GetSecs();

while continueShow
    
    % Get ss & xs from the big matrices. xs and ss are matrices that have
    %  stuff for dots from the last 2 positions + current.
    
    % Ls picks out the previous set (1:5, 6:10, or 11:15)
    Lthis  = Ls(:,1);
    
    
    % This is a matrix of random #s - starting position
    this_s = ss(Lthis,:);
  
    % Compute new locations, L are the dots that will be moved
    L = rand(ndots,1) < coh;
    
    % Offset the selected dots
    this_s(L,:) = this_s(L,:) + dxdy(L,:);
    
    % If not 100% coherence
    if sum(~L) > 0
        
        % Get new random locations for the rest
        this_s(~L,:) = rand(sum(~L),2);
        
    end
    
    % ??????????????????
    N = sum((this_s > 1 | this_s < 0 | repmat(dotTime(:,1) > dotLifeTime,1,2))')' ~= 0 ;  %#ok<UDIM>
    
    % Re-allocate the dots to random positions
    if sum(N) > 0
        
        % Re-allocate the chosen dots to random positions
        this_s(N,:) = rand(sum(N), 2);
        
        % Find the dots that were re-allocated and change its lifetime to 1
        dotTime(find(N==1),:) = 1;
        
    end
    
    %     % Reallocate to the border of the aperture
    %     if sum(N) > 0
    %         xdir = sin(pi*direction/180.0);
    %         ydir = cos(pi*direction/180.0);
    %         % Flip a weighted coin to see which edge to put the replaced dots
    %         if rand < abs(xdir)/(abs(xdir) + abs(ydir))
    %             this_s(find(N==1),:) = [rand(sum(N),1) (xdir > 0)*ones(sum(N),1)];
    %             dotTime(find(N==1),:) = 1;
    %         else
    %             this_s(find(N==1),:) = [(ydir < 0)*ones(sum(N),1) rand(sum(N),1)];
    %             dotTime(find(N==1),:) = 1;
    %         end
    %     end
    
    % Add one frame to the dot lifetime to each dot
    dotTime = dotTime + 1;
    
    % Convert to stuff we can actually plot (pix/ApUnit)
    this_x(:,1:2) = floor(Cfg.diameterAperturePpd(1)*this_s);
    
    % This assumes that zero is at the top left, but we want it to be
    %  in the center, so shift the dots up and left, which just means
    %  adding half of the aperture size to both the x and y direction.
    dotShow = (this_x(:,1:2)-Cfg.diameterAperturePpd/2)';
    
    %% PTB draws the dots stimulation
    
    % Draw the fixation cross
    if GetSecs < (movieStartTime+fixationChangeDuration) && eventIsFixationTarget==1
        
        % Target
        Screen('DrawLines', Cfg.win, Cfg.allCoords, ExpParameters.lineWidthPix, ...
            ExpParameters.fixationCrossColorTarget, [Cfg.center(1) Cfg.center(2)], 1);
        
    else
        
        % Not target
        Screen('DrawLines', Cfg.win, Cfg.allCoords,ExpParameters.lineWidthPix, ...
            ExpParameters.fixationCrossColor , [Cfg.center(1) Cfg.center(2)], 1);
        
    end
    
    % NaN out-of-circle dots
    xyDis = dotShow;
    outCircle = sqrt(xyDis(1,:).^2+xyDis(2,:).^2)+dotSize/2 > (Cfg.diameterAperturePpd/2);
    dots2Display = dotShow;
    dots2Display(:,outCircle) = NaN;
    
    % Draw the dots
    Screen('DrawDots', Cfg.win, dots2Display, dotSize, dotColor, Cfg.center, 2);
    
    Screen('DrawingFinished', Cfg.win, dontClear );
    
    Screen('Flip', Cfg.win, 0, dontClear );
    
    % Update the array so xor works next time ????????
    ss(Lthis, :) = this_s;
    
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

Screen('DrawLines', Cfg.win, Cfg.allCoords, ExpParameters.lineWidthPix, ...
    ExpParameters.fixationCrossColor , [Cfg.center(1) Cfg.center(2)], 1);

Screen('DrawingFinished', Cfg.win,dontClear);

Screen('Flip', Cfg.win, 0, dontClear);

