clear all;
clc

device = 'PC';
fprintf('Connected Device is %s \n\n',device);

Cfg.triggerKey = 't';
Cfg.responseButton = 'f';
numTriggers = 4;

%% Get the subject Name & Run number
sub_name = input('Subject Name: ','s');
if isempty(sub_name)
    sub_name = 'trial';
end

RunNumber = input('Run Number: ','s');
if isempty(RunNumber)
    sub_name = '0';
end

fprintf('MT Localizer Sub:%s  Run:%s \n\n',sub_name,RunNumber);

%% EYE TRACKER
GlobalET=input('Eye Tracker? (y/n)', 's');
if strcmp(GlobalET, 'y')
    GlobalCali=input('Calibration? (y/n)', 's');
    
    if strcmp(GlobalCali, 'y')
        GlobalCustomCali=input('Custom Calibration? (y/n)', 's');
    end
end

%% Experiment Parametes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initial_wait = 2;                                                              % seconds to have a blank screen at the beginning, the scans will be discarded until                                                                              % the magnetic field is homogenous
end_wait = 2;                                                                  % seconds to have a blank screen at the end of the experiment                                                                            % the magnetic field is homogenous
IBI = 6;                                                                       % Inter-block duration in seconds (time between blocks)
numBlocks = 2;                                                                 % Number of Blocks per condition , where 1 block = 1 block of each condition (static and motion)
numEvents = 10;                                                                % Number of events in each block
eventDuration = 1.6;                                                           % Event duration [should be a multiple of osc (below)]
ISI = 0.05;                                                                    % Inter-stimulus interval (blank peroid between individual events)
range_targets = [1 3];                                                         % range of number of targets in each block (from 2 to 5 targets in each block)
minDistanceBetTargets = 2;                                                     % minimum accepted distance between 2 consequtive targets
TargetDuration = 0.1 ;                                                         % fixation cross color will change to red for 100 msec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of cycles per block
nr_cycles = ceil(eventDuration/2) ;                                                       % 1 Cycle = one inward and outward motion together
% function "experimental_design" while assign the blocks, conditions, and
% the number of targets that will be used in the motion localizer
[names,isMotion,isTarget,condition] = experimental_design(numBlocks,numEvents,range_targets,minDistanceBetTargets);
numBlocks = length(names);                                                     % Create a variable with the number of blocks in the whole experiment

%% PTB Setup
screenNumber = max(Screen('Screens'));
%screenNumber = 0;
Screen('Preference', 'SkipSyncTests', 1);       % SHOULD BE SET TO 0 WHEN TESTING
[w, winRect, xMid, yMid] = startPTB(screenNumber, 1, [128 128 128]);
HideCursor;


%% EYE TRACKER INITIATION

if strcmp(GlobalET, 'y') && strcmp(GlobalCali, 'y')
    
    % Eyelink
    
    status = Eyelink('IsConnected');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %fileEdf = ['eye_ExpID', num2str(GlobalExperimentID), '_RunID' num2str(GlobalRunID), '_SubID', num2str(GlobalSubjectID),'.edf'];
    fileEdf = ['eyeTrackerData_', sub_name,'_Run_',RunNumber,'.edf'];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    gray=GrayIndex(screenNumber);
    black=BlackIndex(screenNumber);
    % Open a double buffered fullscreen window on the stimulation screen
    % 'screenNumber', 'w' is the handle
    % used to direct all drawing commands to that window - the "Name" of
    % the window. 'wRect' is a rectangle defining the size of the window.
    % See "help PsychRects" for help on such rectangles and useful helper
    % functions:
    [w, wRect]=Screen('OpenWindow',screenNumber, gray);
    
    [mx, my] = RectCenter(wRect);
    
    % Set text size (Most Screen functions must be called after
    % opening an onscreen window, as they only take window handles 'w' as
    % input:
    Screen('TextSize', w, 32);
    silver=[192 192 192,(w)];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Eyelink
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %     fprintf('EyelinkToolbox Example\n\n\t');
    dummymode=0;       % set to 1 to initialize in dummymode (rather pointless for this example though)
    
    
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(w);
    % Disable key output to Matlab window:
    %     ListenChar(2);
    el.backgroundcolour = silver;
    el.msgfontcolour    = BlackIndex(w);
    
    el.calibrationtargetcolour= BlackIndex(w);
    el.calibrationtargetsize= 1;
    el.calibrationtargetwidth=0.5;
    el.displayCalResults = 1;
    
    EyelinkUpdateDefaults(el);
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [~, vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    % open file to record data to
    edfFile='demo.edf';
    Eyelink('Openfile', edfFile);
    
    %%%%%%%%%%
    % STEP 5 %
    %%%%%%%%%%
    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, 0, 0);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, 0, 0);
    %Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, 1587, 1285);
    %Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, 1587, 1285);
    % set calibration type.
    
    if strcmp(GlobalCustomCali, 'n')
        Eyelink('command', 'calibration_type = HV5');
        % you must send this command with value NO for custom calibration
        % you must also reset it to YES for subsequent experiments
        Eyelink('command', 'generate_default_targets = YES');
        %%%%%% WE WILL NOT USE THAT
        %%%%%% , TRENTO 2/3
    else
        Eyelink('command', 'calibration_type = HV5');
        % you must send this command with value NO for custom calibration
        % you must also reset it to YES for subsequent experiments
        Eyelink('command', 'generate_default_targets = NO');
        
        % STEP 5.1 modify
        % calibration and validation target locations
        [width, height]=Screen('WindowSize', screenNumber);
        %heigth = height*2/3
        Eyelink('command','calibration_samples = 6');
        Eyelink('command','calibration_sequence = 0,1,2,3,4,5');
        Eyelink('command','calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
            640,512, 640,102, 640,614, 128,341, 1152,341 );
        %width/2,height/2,  width/2,height*0.1,  width/2,height*0.6,  width*0.1,height*1/3, width-width*0.1,height*1/3 );
        Eyelink('command','validation_samples = 5');
        Eyelink('command','validation_sequence = 0,1,2,3,4,5');
        Eyelink('command','validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
            640,512, 640,102, 640,614, 128,341, 1152,341 );
        %width/2,height/2,  width/2,height*0.1,  width/2,height*0.6,  width*0.1,height*1/3, width-width*0.1,height*1/3 );
    end
    % set EDF file contents
    % STEP 5.2 retrieve tracker version and tracker software version
    [v,vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    vsn = regexp(vs,'\d','match'); % wont work on EL
    
    EyelinkDoTrackerSetup(el);
    
    
elseif strcmp(GlobalET, 'y') && strcmp(GlobalCali, 'n')
    % Eyelink
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %status = Eyelink('Initialize', [, displayCallbackFunction])
    status = Eyelink('Initialize')
    status = Eyelink('IsConnected')
    
    %fileEdf = ['eye_ExpID', num2str(GlobalExperimentID), '_RunID' num2str(GlobalRunID), '_SubID', num2str(GlobalSubjectID),'.edf'];
    fileEdf = ['eyeTrackerData_', sub_name,'_Run_',RunNumber,'.edf'];
    
    % open file to record data to
    edfFile='demo.edf';
    Eyelink('Openfile', edfFile);
end


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
DrawFormattedText(w,'Press for RED fixation circle','center', 'center', black);
Screen('Flip', w);
KbWait(-1,3)
Screen('Flip', w);

WaitSecs(0.25);

%% FUNCTION
%try
if strcmp(device,'PC')
    
    % TRIGGER
    triggerCounter=0;
    fprintf('Waiting for trigger \n');
    DrawFormattedText(w,['Waiting for trigger'],'center', 'center', black);
    Screen('Flip', w);
    
    % While waiting for each trigger key
    while triggerCounter < numTriggers
        [keyIsDown, ~, KeyCode, ~] = KbCheck(-1);
        if strcmp(KbName(KeyCode),Cfg.triggerKey)  % check that the input is the trigger
            triggerCounter = triggerCounter+1 ;
            fprintf('Trigger %s \n', num2str(triggerCounter));
            DrawFormattedText(w,['Trigger ',num2str(triggerCounter)],'center', 'center', black);
            Screen('Flip', w);
            while keyIsDown  % Wait until key is released
                [keyIsDown, ~, KeyCode, ~] = KbCheck(-1);
            end
        end
    end
end

%% Experiment Start (Main Loop)
experimentStartTime = GetSecs;

%% Scanning Parameters
%(very rough) setting of oscillation frequency
osc = .8;                                                                      % Oscillating in seconds

% Number of frames for one block
nframes  = floor(eventDuration/ifi);
while mod(nframes,nr_cycles)~=0                                                % make sure the nframes are even number
    nframes = nframes-1;                                                       % to be able to re-assign dots in the static condition (to perform divison calculation)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mon_width   = 42;                                                              % Horizontal dimension of viewable screen (cm)
v_dist      = 134;                                                             % Viewing distance from the mirror (cm) "in this script we use mirror"
dot_speed   = 4;                                                               % Dot speed (deg/sec)
ndots       = 120;                                                             % number of dots
min_d       = 0.1;                                                             % minumum radius of  annulus (degrees)
max_d       = 4;  %winRect(3)/(3*2)                                            % maximum radius of  annulus (degrees)
%fix_to_rad  = 10 ;                                                            % distance (in degrees) between fixation and maximum radius of annulus
dot_w       = 0.2;                                                             % width of dot (deg)
fix_r       = 0.03;                                                            % radius of fixation point (deg)
f_kill      = 0.05;                                                            % fraction of dots to kill each frame (limited lifetime)
differentcolors = 0;                                                           % Use a different color for each point if == 1. Use common color white if == 0.
differentsizes  = 0;                                                           % Use different sizes for each point if >= 1. Use one common size if == 0.
waitframes = 1;                                                                % Show new dot-images at each waitframes'th monitor refresh.
reallocate_staticDots = 1 ;                                                    % 0 = static dots will stay in the same position , 1 = static dots will be reallocated in each cycle

Cfg.ShiftX = 0 ;                                                               % Shift of the annulus in visual angle along the X axis (Positive numbers = Right, Negative numbers = Left)
Cfg.ShiftY = 0 ;                                                               % Shift of the annulus in visual angle along the Y axis (Positive numbers = Down, Negative numbers = Up)

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

fix_cord = [[tw/2 th/2]-fix_r*ppd [tw/2 th/2]+fix_r*ppd];

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

%% Convert Shift in X & Y from visual angles to pixels
Cfg.ShiftX = Cfg.ShiftX * ppd;
Cfg.ShiftY = Cfg.ShiftY * ppd;

%% Fixation Cross
cfg.fixCrossDimPix = 10;                              % Set the length of the lines (in Pixels) of the fixation cross
cfg.lineWidthPix   = 4;                               % Set the line width (in Pixels) for our fixation cross
cfg.fixationCross_color = [0 0 0] ;
xCoords = [-cfg.fixCrossDimPix cfg.fixCrossDimPix 0 0];
yCoords = [0 0 -cfg.fixCrossDimPix cfg.fixCrossDimPix];
cfg.allCoords = [xCoords; yCoords];
cfg.center = [tw, th]/2;
%% Experiment start
% The experment will wait (initial_wait)  Secs before running the stimuli
Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);% draw fixation dot (flip erases it)
blank_onset=Screen('Flip', w);
WaitSecs('UntilTime', blank_onset + initial_wait);

targetTime   = [];
responseKey  = [];
responseTime = [];
responseName={};
% Empty variables
blockOnsets = zeros(numBlocks,1);
blockEnds = zeros(numBlocks,1);
blockDurations = zeros(numBlocks,1);
blockNames = cell(numBlocks,1);

eventEnds = zeros(numBlocks,numEvents);
eventOnsets = zeros(numBlocks,numEvents);
eventDurations = zeros(numBlocks,numEvents);
eventNames = cell(numBlocks,numEvents);

% For each block
for iBlock = 1:numBlocks
    
    %% EyeLink Start recording the block
    if strcmp(GlobalET, 'y')
        % Eyelink
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %if Eyelink('CheckRecording');
        Eyelink('StartRecording');
        %end
        
        %Eyelink('message',['TRIALID ',num2str(blocks),'_startTrial']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    blockOnsets(iBlock,1) = GetSecs - experimentStartTime;
    blockNames(iBlock,1) = names(iBlock);
    %% Motion blocks
    if strcmp(blockNames(iBlock,1),'motion')                                      % Check if this block is a motion condition
        
        % For each event inside the motion block
        for iEvent=1:numEvents
            %vbl = Screen('Flip', w, 0, 1);
            vbl = GetSecs();
            
            eventOnsets(iBlock,iEvent) = GetSecs - experimentStartTime;    % Get onset time
            eventNames(iBlock,iEvent) = names(iBlock);
            
            % Get end time
            motionEnd = eventOnsets(iBlock,iEvent) + experimentStartTime +  eventDuration;
            
            for i = 1:nframes   % for each frame
                
                %% Get responseKey and responseTime
                % Use KbCheck if using PC
                % Since these are frames, we need to collect the response
                % button at each frame to get the response time.
                if  strcmp(device,'PC')
                    [KeyIsDown,PressedSecs,KeyCode] = KbCheck(-1);
                    %if KeyIsDown && min(~strcmp(KbName(KeyCode),Cfg.triggerKey))      % IF PROBLEM WITH TRIGGER REGESTERING AS RESPONSE
                    if KeyIsDown && max(strcmp(KbName(KeyCode),Cfg.responseButton))      % IF PROBLEM WITH TRIGGER REGESTERING AS RESPONSE
                        responseKey(end+1)= 1 ;
                        responseTime(end+1)= PressedSecs - experimentStartTime;
                        responseName{end+1}=KbName(KeyCode);
                    else  % if ~KeyIsDown
                        responseKey(end+1)= 0;
                        responseTime(end+1)= 0;
                        responseName{end+1}=KbName(KeyCode);
                    end
                end
                
                if GetSecs <= motionEnd
                    if i>1
                        Screen('DrawDots', w, xymatrix, s, colvect, [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY],1);  % change 1 to 0 to draw square dots
                        %Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
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
                    
                    % plot fixation
                    % if it is a target, change fixation to red
                    if isTarget(iBlock,iEvent) && i<= floor(TargetDuration/ifi)
                        Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, [255 0 0] , [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                    % draw RED fixation cross (flip erases it) [TARGET]
                        targetTime(end+1)=GetSecs-experimentStartTime;
                    else
                        Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                % draw white fixation cross (flip erases it)
                        targetTime(end+1)=0;
                    end
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                    
                    vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
                    
                    
                end
            end
            eventEnds(iBlock,iEvent) = GetSecs - experimentStartTime;
            eventDurations(iBlock,iEvent) = eventEnds(iBlock,iEvent) - eventOnsets(iBlock,iEvent);
            
            Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color ,[cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                             % draw fixation dot (flip erases it)
            vbl=Screen('Flip', w);
            WaitSecs('UntilTime', vbl + ISI);
        end
        
        
        
        %% Static condition
    elseif strcmp(blockNames(iBlock,1),'static')                                    % Check if this block is a static condition
        
        for iEvent=1:numEvents     % for each event
            vbl = GetSecs(); %Screen('Flip', w, 0, 1);
            
            eventOnsets(iBlock,iEvent) = GetSecs - experimentStartTime;  % get event onset
            eventNames(iBlock,iEvent) = names(iBlock);
            % Get end time
            motionEnd = eventOnsets(iBlock,iEvent) + experimentStartTime + eventDuration;
            
            for i= 1:nframes % for each frame
                
                % Get responseKey and responseTime, use KbCheck if using PC
                if  strcmp(device,'PC')
                    [KeyIsDown,PressedSecs,KeyCode] = KbCheck(-1);
                    %if KeyIsDown && min(~strcmp(KbName(KeyCode),Cfg.triggerKey))      % IF PROBLEM WITH TRIGGER REGESTERING AS RESPONSE
                    if KeyIsDown && max(strcmp(KbName(KeyCode),Cfg.responseButton))      % IF PROBLEM WITH TRIGGER REGESTERING AS RESPONSE
                        
                        responseKey(end+1)= 1 ;
                        responseTime(end+1)= PressedSecs - experimentStartTime;
                        responseName{end+1}=KbName(KeyCode);
                    else  %if ~KeyIsDown
                        responseKey(end+1)= 0;
                        responseTime(end+1)= 0;
                        responseName{end+1}=KbName(KeyCode);
                    end
                end
                
                if GetSecs <= motionEnd
                    if i>1 %&& rem(i,10)~=0
                        
                        Screen('DrawDots', w, xymatrix, s, colvect,[cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY],1);  % change 1 to 0 to draw square dots
                        % Screen('DrawingFinished', w);                                % Tell PTB that no further drawing commands will follow before Screen('Flip')
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
                    
                    if reallocate_staticDots == 1
                        
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
                    
                    % plot fixation
                    % Check if it is a target condition
                    if isTarget(iBlock,iEvent) && i<= floor(TargetDuration/ifi)
                        Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, [255 0 0] , [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                     % draw RED fixation dot (flip erases it) [TARGET]
                        targetTime(end+1)=GetSecs-experimentStartTime;
                    else
                        Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                 % draw fixation dot (flip erases it)
                        targetTime(end+1)=0;
                    end
                    
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    
                    
                    vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
                else
                    break;
                end
            end
            
            eventEnds(iBlock,iEvent) = GetSecs - experimentStartTime;
            eventDurations(iBlock,iEvent) = eventEnds(iBlock,iEvent) - eventOnsets(iBlock,iEvent);
            
            Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color ,[cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                             % draw fixation dot (flip erases it)
            vbl=Screen('Flip', w);
            WaitSecs('UntilTime', vbl + ISI);
        end
        
        
    end
    blockEnds(iBlock,1) = GetSecs - experimentStartTime;
    blockDurations(iBlock,1) = blockEnds(iBlock,1) - blockOnsets(iBlock,1);
    
    
    %% EyeLink STOP RECORDING THE BLOCK
    if strcmp(GlobalET, 'y')
        % Eyelink
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Eyelink('message',['TRIALID ',num2str(blocks),'_endTrial'])
        
        %     WaitSecs(0.1);
        %
        %                Eyelink('message',['TRIALID ',num2str(blocks),'_endRecording']);
        %                WaitSecs(0.2);
        Eyelink('stoprecording');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    %% EYELINK - START RECORDING THE IBI
    
    if strcmp(GlobalET, 'y')
        % Eyelink
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %if Eyelink('CheckRecording');
        Eyelink('StartRecording');
        %end
        
        %Eyelink('message',['TRIALID ',num2str(blocks),'_startTrial']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    %% Fixation cross and inter-block interval
    Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                             % draw fixation dot (flip erases it)
    blank_onset=Screen('Flip', w);
    WaitSecs('UntilTime', blank_onset + IBI);                                    % wait for the inter-block interval
    
    %% EYELINK - STOP RECORDING THE IBI
    if strcmp(GlobalET, 'y')
        % Eyelink
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Eyelink('message',['TRIALID ',num2str(blocks),'_endTrial'])
        
        %     WaitSecs(0.1);
        %
        %                Eyelink('message',['TRIALID ',num2str(blocks),'_endRecording']);
        %                WaitSecs(0.2);
        Eyelink('stoprecording');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end;
end

%%
% At the end of the blocks wait ... secs before ending the experiment.
Screen('DrawLines', w, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color ,[cfg.center(1)+Cfg.ShiftX cfg.center(2)+Cfg.ShiftY], 1);	                             % draw fixation dot (flip erases it)
blank_onset=Screen('Flip', w);
WaitSecs('UntilTime', blank_onset + end_wait);

% KeyPresses and Times
for i=length(responseKey):-1:2                                                   % responseKey gives a '1' in all frames where button was pressed, so one motor response = gives multiple consequitive '1' frames
    if responseKey(i-1)~=0                                                       % therefore, we need to cancel consequitive '1' frames after the first button press
        responseKey(i)=0;                                                        % we loop through the responses and remove '1's that are not preceeded by a zero
        responseTime(i)=0;                                                       % this way, we remove the additional 1s for the same button response
    end                                                                          % - The same concept for the responseTime
end

for i=length(targetTime):-1:2                                                   % The same concept as responseKey adn responseTime.
    if targetTime(i-1)~=0
        targetTime(i)=0;                                                        % we remove targets that are preceeded by a non-zero value
    end                                                                          % that way, we have the time of the first frame only of the target
end

NonZeroIdx = responseKey > 0;
responseKey  = responseKey(NonZeroIdx);                                         % Remove zero elements from responseKey, responseTime, & targetTime
responseName = responseName(NonZeroIdx);
responseTime = responseTime(responseTime > 0);
targetTime   = targetTime(targetTime > 0);

%% Shutdown Procedures
ShowCursor;
clear screen;
myTotalSecs=GetSecs;
Experiment_duration = myTotalSecs - experimentStartTime;

%% Save a mat Log file
% Onsets & durations are saved in seconds.
save(['logFileFull_',sub_name,'_Run_',RunNumber,'.mat']);
save(['logFile_',sub_name,'_Run_',RunNumber,'.mat'], 'blockNames','blockOnsets','blockDurations','blockEnds','responseTime','responseKey','targetTime','Experiment_duration');


if strcmp(GlobalET, 'y')
    % Eyelink
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Eyelink('CloseFile');
    WaitSecs(1);
    status = Eyelink('receivefile','',fileEdf);
    %Eyelink('shutdown');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end