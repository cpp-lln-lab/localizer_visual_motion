%function mirror_runMTLocalizer

% 7 trials : 310.8743 sec = 5.18 minutes
%  310.8743 = 156 TR + 4 trigger = 160 TRs
clear all;
clc

%% To correct for the y-axis problem inside the scanner
%  where the lower 1/3 of the screen is not appearing because of coil
%  indicate which device the script is running on, on PC, the middle of the
%  y axis will be the middle of the screen, on the Scanner, the middle of
%  y-axis will be the middle of the upper 2/3 of the screen, because the
%  lower 1/3 is not visible due to the coil in the scanner.

%device = 'Scanner';
device = 'PC';

fprintf('Connected Device is %s \n\n',device);

% Original Script Written by Sam Weiller to localize MT+/V5
% Adapted by M.Rezk 
%% Start me up
% Get the subject Name
sub_name = input('Subject Name: ','s');
       if isempty(sub_name)
          sub_name = 'trial';
       end

disp('MT Localizer')

%% Experiment Parametes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initial_wait = 2;                                                             % seconds to have a blank screen at the beginning, the scans will be discarded until                                                                              % the magnetic field is homogenous                                                                         
blockDur = 16;                                                                 % Block duration [should be a multiple of osc (below)]                                                                               
ibi = 8;                                                                       % Inter-block duration in seconds (time between blocks)
nr_trials = 7;                                                                 % Number of trials , where 1 trial = 1 block of all conditions (static and motion)
range_targets = [2 4];                                                         % range of number of targets in each block (from 2 to 5 targets in each block)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of cycles per block 
nr_cycles = blockDur/2 ;                                                       % 1 Cycle = one inward and outward motion together
% function "experimental_design" while assign the blocks, conditions, and 
% the number of targets that will be used in the motion localizer
[names,targets,condition] = experimental_design(nr_trials,range_targets);  
numBlocks = length(names);                                                     % Create a variable with the number of blocks in the whole experiment

%% PTB Setup
screenNumber = max(Screen('Screens'));
%screenNumber = 0;
Screen('Preference', 'SkipSyncTests', 2);
[w, winRect, xMid, yMid] = startPTB(screenNumber, 1, [128 128 128]);
HideCursor;

%% Color indeces, and Screen parameters and inter-flip interval.  
% Color indices
white = WhiteIndex(screenNumber);                        
black = BlackIndex(screenNumber);
grey = ceil((white+black)/2);

% Flip interval and screen size
ifi = Screen('GetFlipInterval', w);                                            % Get the flip interval
[tw, th] = Screen('WindowSize', w);      

%% Welcome screen
Screen('TextFont',w, 'Courier New');
Screen('TextSize',w, 20);
Screen('TextStyle', w, 1);
DrawFormattedText(w,'Press for RED fixation circle',...
            'center', 'center', black);
Screen('Flip', w);
[KeyIsDown, pend, KeyCode]=KbCheck;
KbWait;
Screen('Flip', w);

WaitSecs(0.25);

%% FUNCTION

if strcmp(device,'PC')
    DrawFormattedText(w,'Waiting For Trigger',...
        'center', 'center', black);
    Screen('Flip', w);
    
    % press key
    KbWait();
    KeyIsDown=1;
    while KeyIsDown>0
        [KeyIsDown, ~, ~]=KbCheck;
    end
    
    % open Serial Port "SerPor" - COM1 (BAUD RATE: 11520)
elseif strcmp(device,'Scanner')
    DrawFormattedText(w,'Waiting For Trigger','center', 'center', black);
    Screen('Flip', w);
    SerPor = MT_portAndTrigger;
    Screen('Flip', w);
end

%% Experiment Start (Main Loop)
experimentStartTime = GetSecs;

%% To correct for the y-axis problem inside the scanner
if strcmp(device,'Scanner')
    adjusted_yAxis = 2/3*th;        %  where the lower 1/3 of the screen is not appearing because of coil
elseif strcmp(device,'PC')
    adjusted_yAxis = th;            %  y-axis is the same, no changes
end

%% Scanning Parameters
%(very rough) setting of oscillation frequency
osc = .8;                                                                      % Oscillating in seconds

% Number of frames for one block
nframes  = floor(blockDur/ifi);
while mod(nframes,nr_cycles)~=0                                                % make sure the nframes are even number
    nframes = nframes-1;                                                       % to be able to re-assign dots in the static condition (to perform divison calculation)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mirror_width= 42;                                                            % Width (x-axis) of the mirror (in cm)
mon_width  = 42;                                                              % horizontal dimension of viewable screen (cm)
v_dist      = 134;                                                              % viewing distance from the mirror (cm) "in this script we use mirror"
dot_speed   = 4;                                                               % dot speed (deg/sec)
ndots       = 120;                                                             % number of dots
min_d       = 0.1;                                                             % minumum radius of  annulus (degrees)
max_d       = 4;  %winRect(3)/(3*2)                                           % maximum radius of  annulus (degrees)
%fix_to_rad  = 10 ;                                                            % distance (in degrees) between fixation and maximum radius of annulus               
dot_w       = 0.1;                                                             % width of dot (deg)
fix_r       = 0.03;                                                            % radius of fixation point (deg)
f_kill      = 0.05;                                                            % fraction of dots to kill each frame (limited lifetime)
differentcolors = 0;                                                           % Use a different color for each point if == 1. Use common color white if == 0.
differentsizes  = 0;                                                           % Use different sizes for each point if >= 1. Use one common size if == 0.
waitframes = 1;                                                                % Show new dot-images at each waitframes'th monitor refresh.
reallocate_staticDots = 0 ;                                                    % 0 = static dots will stay in the same position , 1 = static dots will be
                                                                               % reallocated in each cycle (2 seconds)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ppd = pi * (winRect(3)-winRect(1)) / atan(mon_width/v_dist/2) / 360;          % pixels per degree
%[mirrorPixelPerDegree] = mirror2Pixels (winRect,v_dist,mirror_width) ;         % Calculate pixel per degree on the mirror surface
pfs = (ppd * dot_speed) / (1/ifi);                            % dot speed (pixels/frame)
s = dot_w * ppd;                                              % dot size (pixels)
rmax = max_d *ppd;	                                                   % maximum radius of annulus (1/4th of the x-axis)
rmin = min_d * ppd;                                           % minimum radius of annulus
r = rmax * sqrt(rand(ndots,1));	                                               % r
r(r<rmin) = rmin;
t = 2*pi*rand(ndots,1);                                                        % theta polar coordinate
cs = [cos(t), sin(t)];
xy = [r r] .* cs;                                                              % dot positions in Cartesian coordinates (pixels from center)

mdir = ones(ndots,1);                                                          %2 * floor(rand(ndots,1)+0.5) - 1;    % motion direction (in or out) for each dot
dr = pfs * mdir;                                                               % change in radius per frame (pixels)
dxdy = [dr dr] .* cs;                                                          % change in x and y per frame (pixels)

fix_cord = [[tw/2 adjusted_yAxis/2]-fix_r*ppd [tw/2 adjusted_yAxis/2]+fix_r*ppd];

% Create a vector with different colors for each single dot, if
% requested:
if (differentcolors==1)
    % colvect = uint8(round(rand(3,ndots)*255));
    colvect = grey + (grey-1)* (2 * floor(rand(ndots,1)+0.5) - 1);
    colvect = [colvect colvect colvect]';
else
    colvect=white;
end;

% Create a vector with different point sizes for each single dot, if
% requested:
if (differentsizes>0)
    s=(1+rand(1, ndots)*(differentsizes-1))*s;
end;


%% Fixation Cross
cfg.fixCrossDimPix = 10;                            % Set the length of the lines (in Pixels) of the fixation cross
cfg.lineWidthPix   = 4;                               % Set the line width (in Pixels) for our fixation cross
cfg.fixationCross_color = [0 0 0] ;                            
xCoords = [-cfg.fixCrossDimPix cfg.fixCrossDimPix 0 0];
yCoords = [0 0 -cfg.fixCrossDimPix cfg.fixCrossDimPix];
cfg.allCoords = [xCoords; yCoords];
cfg.center = [tw, adjusted_yAxis]/2;
%% Experiment start
% The experment will wait (initial_wait)  Secs before running the stimuli
Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);% draw fixation dot (flip erases it)
blank_onset=Screen('Flip', w);
WaitSecs('UntilTime', blank_onset + initial_wait);

targetTime   = [];
responseKey  = [];
responseTime = [];

for blocks = 1:numBlocks
    timeLogger.block(blocks).startTime = GetSecs - experimentStartTime;        % Get the start time of the block
    timeLogger.block(blocks).condition = condition(blocks);                    % Get the condition of the block (motion or static)
    timeLogger.block(blocks).names = names(blocks);                            % Get the name of the block (l_motion or r_motion or r/l_static)
    

    %% Motion blocks
    if strcmp(condition(blocks),'motion')                                      % Check if this block is a motion condition
        motionStartLog = GetSecs;
        motionEnd = motionStartLog + blockDur;                                 % Define when the animation loop will stop
        
        %Define the targets for this block
        targets_inside_block = assignTargets_insideBlock (nframes,blockDur,ifi,targets(blocks));
        vbl = Screen('Flip', w, 0, 1);
        
        % --------------
        % animation loop
        % --------------

        for i = 1:nframes
            
            if targets_inside_block(i)==0;                                      % if it is not a target frame 
                Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                % draw white fixation cross (flip erases it)
                targetTime(end+1)=0;
            elseif targets_inside_block(i)==1;
                Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, [255 0 0] , [cfg.center(1) cfg.center(2)], 1);	                    % draw RED fixation cross (flip erases it) [TARGET]
                targetTime(end+1)=GetSecs-experimentStartTime;
            end    
            
            %% Get responseKey and responseTime 
            % Use KbCheck if using PC , or MT_TakeSerialButtonPerFrame if using fMRI
            % Since these are frames, we need to collect the response
            % button at each frame to get the response time.
            if strcmp(device,'Scanner')
                [sbutton,secs] = MT_TakeSerialButtonPerFrame(SerPor);
                responseKey(end+1)= sbutton;
                responseTime(end+1)= secs - experimentStartTime;
            elseif  strcmp(device,'PC')
                [KeyIsDown,PressedSecs,KeyCode] = KbCheck(-1);
                if KeyIsDown
                    responseKey(end+1)= 1 ;
                    responseTime(end+1)= PressedSecs - experimentStartTime;
                elseif ~KeyIsDown
                    responseKey(end+1)= 0;
                    responseTime(end+1)= 0;
                end
            end
            
            if GetSecs <= motionEnd
                if i>1
                    
                    %Screen('DrawDots', w, xymatrix, s, colvect, [(tw/2+(direction(blocks)*(tw/4+rmax))) (adjusted_yAxis/2)],1);  % change 1 to 0 to draw square dots
                    Screen('DrawDots', w, xymatrix, s, colvect, [(tw/2) (adjusted_yAxis/2)],1);  % change 1 to 0 to draw square dots
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                end
                
                mdir = ones(ndots,1) * mod(ceil(i/(nframes/(nr_cycles*2))),2)*2-1;
                dr = pfs * mdir;                                                % change in radius per frame (pixels)
                dxdy = [dr dr] .* cs;                                           % change in x and y per frame (pixels)
                
                xy = xy + dxdy;						                            % move dots
                r = r + dr;							                            % update polar coordinates too
                
                r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill);	    % dots to reposition if they are outside the aperture
                nout = length(r_out);
                
                if nout
                    r(r_out) = rmax * sqrt(rand(nout,1));
                    r(r<rmin) = rmin;
                    t(r_out) = 2*pi*(rand(nout,1));
                    
                    cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                    xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                    
                    dxdy(r_out,:) = [dr(r_out) dr(r_out)] .* cs(r_out,:);
                end;
                xymatrix = transpose(xy);
                
                vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
                
            else
                break;
            end;
        end;

    %% Static condition 
    elseif strcmp(condition(blocks),'static')                                    % Check if this block is a static condition
        motionStartLog = GetSecs;
        motionEnd = motionStartLog + blockDur;
        
        %Define the targets for this block
        targets_inside_block = assignTargets_insideBlock (nframes,blockDur,ifi,targets(blocks));
        
        vbl = Screen('Flip', w, 0, 1);
        for i= 1:nframes
            if targets_inside_block(i)==0;
                Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                 % draw fixation dot (flip erases it)
                targetTime(end+1)=0;
            elseif targets_inside_block(i)==1;
                Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, [255 0 0] , [cfg.center(1) cfg.center(2)], 1);	                     % draw RED fixation dot (flip erases it) [TARGET]
                targetTime(end+1)=GetSecs-experimentStartTime;
            end
            
            % Get responseKey and responseTime
            % Use KbCheck if using PC , or MT_TakeSerialButtonPerFrame if
            % using fMRI            
            if strcmp(device,'Scanner')
                [sbutton,secs] = MT_TakeSerialButtonPerFrame(SerPor);
                responseKey(end+1)= sbutton;
                responseTime(end+1)= secs - experimentStartTime;
            elseif  strcmp(device,'PC')
                [KeyIsDown,PressedSecs,KeyCode] = KbCheck(-1);
                if KeyIsDown
                    responseKey(end+1)= 1 ;
                    responseTime(end+1)= PressedSecs - experimentStartTime;
                elseif ~KeyIsDown
                    responseKey(end+1)= 0;
                    responseTime(end+1)= 0;
                end
            end
     
            if GetSecs <= motionEnd
                if i>1 %&& rem(i,10)~=0
                    
                    Screen('DrawDots', w, xymatrix, s, colvect, [(tw/2) (adjusted_yAxis/2)],1);  % change 1 to 0 to draw square dots
                    Screen('DrawingFinished', w);                                % Tell PTB that no further drawing commands will follow before Screen('Flip')
                end
                
                r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill/100);	 % dots to reposition if they are outside the aperture
                nout = length(r_out);
                
                if nout && ~mod(i/(nframes/4),2)
                    r(r_out) = rmax * sqrt(rand(nout,1));
                    r(r<rmin) = rmin;
                    t(r_out) = 2*pi*(rand(nout,1));
                    
                    cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                    xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                    
                    dxdy(r_out,:) = [dr(r_out) dr(r_out)] .* cs(r_out,:);
                end;
                
                if reallocate_staticDots == 1 ; 
                    
                    % For the static condition, re-create the dots at different 
                    %locations with every cycle interval to prevent adaptation.
                    for cycle_num = 1:nr_cycles
                        if i==(nframes/nr_cycles)*cycle_num                          % If this frams is the end of the cycle frame, re-run the random assignment of dots at new posiions
                            t = 2*pi*rand(ndots,1);                                  % theta polar coordinate
                            cs = [cos(t), sin(t)];
                            xy = [r r] .* cs;                                        % dot positions in Cartesian coordinates (pixels from center)
                        end
                    end
                end
                    
                xymatrix = transpose(xy);
                vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
            else
                break;
            end;
        end
        
    end
    
    timeLogger.block(blocks).endTime = GetSecs - experimentStartTime;            % Get the time for the block end
    timeLogger.block(blocks).length  = timeLogger.block(blocks).endTime - timeLogger.block(blocks).startTime;  %Get the block duration
    
    %% Fixation cross and inter-block interval
    Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                             % draw fixation dot (flip erases it)
    blank_onset=Screen('Flip', w);
    WaitSecs('UntilTime', blank_onset + ibi);                                    % wait for the inter-block interval
    
end;

% At the end of the blocks wait ... secs before ending the experiment.
Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                             % draw fixation dot (flip erases it)
blank_onset=Screen('Flip', w);
WaitSecs('UntilTime', blank_onset + initial_wait);


%% Save the results ('names','onsets','ends','duration') of each block
names     = cell(length(timeLogger.block),1);
onsets    = zeros(length(timeLogger.block),1);
ends      = zeros(length(timeLogger.block),1);
durations = zeros(length(timeLogger.block),1);

for i=1:length(timeLogger.block)
    names(i,1)     = timeLogger.block(i).names;
    onsets(i,1)    = timeLogger.block(i).startTime;
    ends(i,1)      = timeLogger.block(i).endTime;
    durations(i,1) = timeLogger.block(i).length;
end

%% KeyPresses and Times
for i=length(responseKey):-1:2                                                   % responseKey gives a '1' in all frames where button was pressed, so one motor response = gives multiple consequitive '1' frames
    if responseKey(i-1)~=0                                                       % therefore, we need to cancel consequitive '1' frames after the first button press
        responseKey(i)=0;                                                        % we loop through the responses and remove '1's that are not preceeded by a zero
        responseTime(i)=0;                                                       % this way, we remove the additional 1s for the same button response
    end                                                                          % - The same concept for the responseTime
end

for i=length(targetTime):-1:2                                                   % The same concept as responseKey adn responseTime.
    if targetTime(i-1)~=0                                                       % Our Targets lasts 3 frames, to remove the TargetTime for the 2nd and 3rd frame
        targetTime(i)=0;                                                        % we remove targets that are preceeded by a non-zero value
    end                                                                          % that way, we have the time of the first frame only of the target
end

responseKey  = responseKey(responseKey > 0);                                       % Remove zero elements from responseKey, responseTime, & targetTime
responseTime = responseTime(responseTime > 0);
targetTime   = targetTime(targetTime > 0);

%% Shutdown Procedures
ShowCursor;
clear screen;
myTotalSecs=GetSecs;
Experiment_duration = myTotalSecs - experimentStartTime;

%% Save a mat Log file
% Onsets & durations are saved in seconds.
save(['logFileFull_',sub_name,'.mat']);
save(['logFile_',sub_name,'.mat'], 'names','onsets','durations','ends','targets','responseTime','responseKey','targetTime','Experiment_duration');


%% FUNCTION
% close Serial Port ----  VERY IMPORTANT NOT FORGET
if strcmp(device,'Scanner')
    CloseSerialPort(SerPor);
end

