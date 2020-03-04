%% Visual motion hMT localizer
%
% Original Script Written by Sam Weiller to localize MT+/V5
% Adapted by M.Rezk
% Updated by M.Barilari

% % % To correct for the y-axis problem inside the scanner
% % %  where the lower 1/3 of the screen is not appearing because of coil
% % %  indicate which device the script is running on, on PC, the middle of the
% % %  y axis will be the middle of the screen, on the Scanner, the middle of
% % %  y-axis will be the middle of the upper 2/3 of the screen, because the
% % %  lower 1/3 is not visible due to the coil in the scanner.

% % % 7 trials : 310.8743 sec = 5.18 minutes
% % %  310.8743 = 156 TR + 4 trigger = 160 TRs

% clear all;
% clc

% make sure we got access to all the required functions and inputs
addpath(fullfile(pwd, 'subfun'))
addpath(fullfile(pwd, 'input'))

% set and load all the parameters to run the experiment
[subjectName, runNumber, sessionNumber] = UserInputs;
[ExpParameters, Cfg] = SetParameters();





% % % fprintf('Connected Device is %s \n\n',Cfg.Device);  MOVE THIS IN THE SET PAREMETERS FUNC AT THE END
% % % disp('MT Localizer') MOVE THIS IN THE SET PAREMETERS FUNC AT THE END




%% Experiment

% Safety loop: close the screen if code crashes
try
    %% Init the experiment
    [Cfg] = InitPTB(Cfg);
    
    % Assign the blocks, conditions, and the number of targets that will be used in the motion localizer
    [ExpParameters] = ExpDesign(ExpParameters);
    
    
    % Show the instruction on the screen
    if ExpParameters.Task1
        DrawFormattedText(Cfg.win, ExpParameters.TaskInstruction, ...
            'center', 'center', Cfg.textColor);
        Screen('Flip', Cfg.win);
    end
    
    % Wait for space key to be pressed
    pressSpace4me
    
    WaitSecs(0.25);
    
    % % %     TRIGGER
    % % %     if strcmp(Cfg.Device,'PC')
    % % %         DrawFormattedText(Cfg.win,'Waiting For Trigger',...
    % % %             'center', 'center', Cfg.Black);
    % % %         Screen('Flip', Cfg.win);
    % % %
    % % %         % press key
    % % %         KbWait();
    % % %         KeyIsDown=1;
    % % %         while KeyIsDown>0
    % % %             [KeyIsDown, ~, ~]=KbCheck;
    % % %         end
    % % %
    % % %         % open Serial Port "SerPor" - COM1 (BAUD RATE: 11520)
    % % %     elseif strcmp(Cfg.Device,'Scanner')
    % % %         DrawFormattedText(Cfg.win,'Waiting For Trigger','center', 'center', Cfg.Black);
    % % %         Screen('Flip', Cfg.win);
    % % %         SerPor = MT_portAndTrigger;
    % % %         Screen('Flip', Cfg.win);
    % % %     end
    
    %% Experiment Start (Main Loop)
    experimentStartTime = GetSecs;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    %% Scanning Parameters
    
    % Number of frames for one block
    nframes  = floor(ExpParameters.blockDur/Cfg.ifi);
    while mod(nframes,ExpParameters.nrCycles)~=0                                                % make sure the nframes are even number
        nframes = nframes-1;                                                       % to be able to re-assign dots in the static condition (to perform divison calculation)
    end
    
    
    ppd = pi * (Cfg.winRect(3)-Cfg.winRect(1)) / atan(Cfg.monitor_width/Cfg.screen_distance/2) / 360;          % pixels per degree
    %[mirrorPixelPerDegree] = mirror2Pixels (Cfg.winRect,Cfg.screen_distance,mirror_width) ;         % Calculate pixel per degree on the mirror surface
    pfs = (ppd * ExpParameters.dot_speed) / (1/Cfg.ifi);                            % dot speed (pixels/frame)
    s = ExpParameters.dot_w * ppd;                                              % dot size (pixels)
    rmax = ExpParameters.max_d *ppd;	                                                   % maximum radius of annulus (1/4th of the x-axis)
    rmin = ExpParameters.min_d * ppd;                                           % minimum radius of annulus
    r = rmax * sqrt(rand(ExpParameters.ndots,1));	                                               % r
    r(r<rmin) = rmin;
    t = 2*pi*rand(ExpParameters.ndots,1);                                                        % theta polar coordinate
    cs = [cos(t), sin(t)];
    xy = [r r] .* cs;                                                              % dot positions in Cartesian coordinates (pixels from center)
    
    mdir = ones(ExpParameters.ndots,1);                                                          %2 * floor(rand(ExpParameters.ndots,1)+0.5) - 1;    % motion direction (in or out) for each dot
    dr = pfs * mdir;                                                               % change in radius per frame (pixels)
    dxdy = [dr dr] .* cs;                                                          % change in x and y per frame (pixels)
    
    fix_cord = [[Cfg.winRect(1,3)/2 Cfg.winRect(1,4)/2]-ExpParameters.fix_r*ppd [Cfg.winRect(1,3)/2 Cfg.winRect(1,4)/2]+ExpParameters.fix_r*ppd];
    
    % Create a vector with different colors for each single dot, if
    % requested:
    if (ExpParameters.differentcolors==1)
        % colvect = uint8(round(rand(3,ExpParameters.ndots)*255));
        colvect = Cfg.Grey + (Cfg.Grey-1)* (2 * floor(rand(ExpParameters.ndots,1)+0.5) - 1);
        colvect = [colvect colvect colvect]';
    else
        colvect=Cfg.White;
    end;
    
    % Create a vector with different point sizes for each single dot, if
    % requested:
    if (ExpParameters.differentsizes>0)
        s=(1+rand(1, ExpParameters.ndots)*(ExpParameters.differentsizes-1))*s;
    end;
    
    
    %% Fixation Cross
    cfg.fixCrossDimPix = 10;                            % Set the length of the lines (in Pixels) of the fixation cross
    cfg.lineWidthPix   = 4;                               % Set the line width (in Pixels) for our fixation cross
    cfg.fixationCross_color = [0 0 0] ;
    xCoords = [-cfg.fixCrossDimPix cfg.fixCrossDimPix 0 0];
    yCoords = [0 0 -cfg.fixCrossDimPix cfg.fixCrossDimPix];
    cfg.allCoords = [xCoords; yCoords];
    cfg.center = [Cfg.winRect(1,3), Cfg.winRect(1,4)]/2;
    %% Experiment start
    % The experment will wait (ExpParameters.onsetDelay)  Secs before running the stimuli
    Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);% draw fixation dot (flip erases it)
    blank_onset=Screen('Flip', Cfg.win);
    WaitSecs('UntilTime', blank_onset + ExpParameters.onsetDelay);
    
    targetTime   = [];
    responseKey  = [];
    responseTime = [];
    
    for blocks = 1:ExpParameters.nrBlocks
        timeLogger.block(blocks).startTime = GetSecs - experimentStartTime;        % Get the start time of the block
        timeLogger.block(blocks).condition = ExpParameters.condition(blocks);                    % Get the condition of the block (motion or static)
        timeLogger.block(blocks).names = ExpParameters.names(blocks);                            % Get the name of the block (l_motion or r_motion or r/l_static)
        
        
        %% Motion blocks
        if strcmp(ExpParameters.condition(blocks),'motion')                                      % Check if this block is a motion condition
            motionStartLog = GetSecs;
            motionEnd = motionStartLog + ExpParameters.blockDur;                                 % Define when the animation loop will stop
            
            %Define the targets for this block
            targets_inside_block = assignTargets_insideBlock (nframes,ExpParameters.blockDur,Cfg.ifi,ExpParameters.targets(blocks));
            vbl = Screen('Flip', Cfg.win, 0, 1);
            
            % --------------
            % animation loop
            % --------------
            
            for i = 1:nframes
                
                if targets_inside_block(i)==0;                                      % if it is not a target frame
                    Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                % draw white fixation cross (flip erases it)
                    targetTime(end+1)=0;
                elseif targets_inside_block(i)==1;
                    Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, [255 0 0] , [cfg.center(1) cfg.center(2)], 1);	                    % draw RED fixation cross (flip erases it) [TARGET]
                    targetTime(end+1)=GetSecs-experimentStartTime;
                end
                
                %% Get responseKey and responseTime
                % Use KbCheck if using PC , or MT_TakeSerialButtonPerFrame if using fMRI
                % Since these are frames, we need to collect the response
                % button at each frame to get the response time.
                if strcmp(Cfg.Device,'Scanner')
                    [sbutton,secs] = MT_TakeSerialButtonPerFrame(SerPor);
                    responseKey(end+1)= sbutton;
                    responseTime(end+1)= secs - experimentStartTime;
                elseif  strcmp(Cfg.Device,'PC')
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
                        
                        %Screen('DrawDots', w, xymatrix, s, colvect, [(Cfg.winRect(1,3)/2+(direction(blocks)*(Cfg.winRect(1,3)/4+rmax))) (Cfg.winRect(1,4)/2)],1);  % change 1 to 0 to draw square dots
                        Screen('DrawDots', Cfg.win, xymatrix, s, colvect, [(Cfg.winRect(1,3)/2) (Cfg.winRect(1,4)/2)],1);  % change 1 to 0 to draw square dots
                        Screen('DrawingFinished', Cfg.win); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    end
                    
                    mdir = ones(ExpParameters.ndots,1) * mod(ceil(i/(nframes/(ExpParameters.nrCycles*2))),2)*2-1;
                    dr = pfs * mdir;                                                % change in radius per frame (pixels)
                    dxdy = [dr dr] .* cs;                                           % change in x and y per frame (pixels)
                    
                    xy = xy + dxdy;						                            % move dots
                    r = r + dr;							                            % update polar coordinates too
                    
                    r_out = find(r > rmax | r < rmin | rand(ExpParameters.ndots,1) < ExpParameters.f_kill);	    % dots to reposition if they are outside the aperture
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
                    
                    vbl=Screen('Flip', Cfg.win, vbl + (ExpParameters.waitframes-0.5)*Cfg.ifi);
                    
                else
                    break;
                end;
            end;
            
            %% Static condition
        elseif strcmp(ExpParameters.condition(blocks),'static')                                    % Check if this block is a static condition
            motionStartLog = GetSecs;
            motionEnd = motionStartLog + ExpParameters.blockDur;
            
            %Define the targets for this block
            targets_inside_block = assignTargets_insideBlock (nframes,ExpParameters.blockDur,Cfg.ifi,ExpParameters.targets(blocks));
            
            vbl = Screen('Flip', Cfg.win, 0, 1);
            for i= 1:nframes
                if targets_inside_block(i)==0;
                    Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                 % draw fixation dot (flip erases it)
                    targetTime(end+1)=0;
                elseif targets_inside_block(i)==1;
                    Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, [255 0 0] , [cfg.center(1) cfg.center(2)], 1);	                     % draw RED fixation dot (flip erases it) [TARGET]
                    targetTime(end+1)=GetSecs-experimentStartTime;
                end
                
                % Get responseKey and responseTime
                % Use KbCheck if using PC , or MT_TakeSerialButtonPerFrame if
                % using fMRI
                if strcmp(Cfg.Device,'Scanner')
                    [sbutton,secs] = MT_TakeSerialButtonPerFrame(SerPor);
                    responseKey(end+1)= sbutton;
                    responseTime(end+1)= secs - experimentStartTime;
                elseif  strcmp(Cfg.Device,'PC')
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
                        
                        Screen('DrawDots', Cfg.win, xymatrix, s, colvect, [(Cfg.winRect(1,3)/2) (Cfg.winRect(1,4)/2)],1);  % change 1 to 0 to draw square dots
                        Screen('DrawingFinished', Cfg.win);                                % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    end
                    
                    r_out = find(r > rmax | r < rmin | rand(ExpParameters.ndots,1) < ExpParameters.f_kill/100);	 % dots to reposition if they are outside the aperture
                    nout = length(r_out);
                    
                    if nout && ~mod(i/(nframes/4),2)
                        r(r_out) = rmax * sqrt(rand(nout,1));
                        r(r<rmin) = rmin;
                        t(r_out) = 2*pi*(rand(nout,1));
                        
                        cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                        xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                        
                        dxdy(r_out,:) = [dr(r_out) dr(r_out)] .* cs(r_out,:);
                    end;
                    
                    if ExpParameters.reallocate_staticDots == 1 ;
                        
                        % For the static condition, re-create the dots at different
                        %locations with every cycle interval to prevent adaptation.
                        for cycle_num = 1:ExpParameters.nrCycles
                            if i==(nframes/ExpParameters.nrCycles)*cycle_num                          % If this frams is the end of the cycle frame, re-run the random assignment of dots at new posiions
                                t = 2*pi*rand(ExpParameters.ndots,1);                                  % theta polar coordinate
                                cs = [cos(t), sin(t)];
                                xy = [r r] .* cs;                                        % dot positions in Cartesian coordinates (pixels from center)
                            end
                        end
                    end
                    
                    xymatrix = transpose(xy);
                    vbl=Screen('Flip', Cfg.win, vbl + (ExpParameters.waitframes-0.5)*Cfg.ifi);
                else
                    break;
                end;
            end
            
        end
        
        timeLogger.block(blocks).endTime = GetSecs - experimentStartTime;            % Get the time for the block end
        timeLogger.block(blocks).length  = timeLogger.block(blocks).endTime - timeLogger.block(blocks).startTime;  %Get the block duration
        
        %% Fixation cross and inter-block interval
        Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                             % draw fixation dot (flip erases it)
        blank_onset=Screen('Flip', Cfg.win);
        WaitSecs('UntilTime', blank_onset + ExpParameters.IBI);                                    % wait for the inter-block interval
        
    end;
    
    % At the end of the blocks wait ... secs before ending the experiment.
    Screen('DrawLines', Cfg.win, cfg.allCoords,cfg.lineWidthPix, cfg.fixationCross_color , [cfg.center(1) cfg.center(2)], 1);	                             % draw fixation dot (flip erases it)
    blank_onset=Screen('Flip', Cfg.win);
    WaitSecs('UntilTime', blank_onset + ExpParameters.onsetDelay);
    
    
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
    

    
    %% Save a mat Log file
    % Onsets & durations are saved in seconds.
    save(['logFileFull_',sub_name,'.mat']);
    save(['logFile_',sub_name,'.mat'], 'names','onsets','durations','ends','targets','responseTime','responseKey','targetTime','Experiment_duration');
    
    
    %% FUNCTION
    % close Serial Port ----  VERY IMPORTANT NOT FORGET
    if strcmp(Cfg.Device,'Scanner')
        CloseSerialPort(SerPor);
    end
    
    %% Shutdown Procedures
    myTotalSecs=GetSecs;
    Experiment_duration = myTotalSecs - experimentStartTime;
    
    
catch
    % If code crashes, close the screen and display the last error
    sca;
    ShowCursor;
%     clear Screen;
    error(lasterror) % show default error
end