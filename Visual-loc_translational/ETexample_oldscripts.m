if strcmp(GlobalET, 'y') && strcmp(GlobalCali, 'y')
    
    % Eyelink
    
    status = Eyelink('IsConnected');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileEdf = ['eye_ExpID', num2str(GlobalExperimentID), '_RunID' num2str(GlobalRunID), '_SubID', num2str(GlobalSubjectID),'.edf'];
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
    
    fileEdf = ['eye_ExpID', num2str(GlobalExperimentID), '_RunID' num2str(GlobalRunID), '_SubID', num2str(GlobalSubjectID),'.edf'];
    % open file to record data to
    edfFile='demo.edf';
    Eyelink('Openfile', edfFile);
end

for i = 1:1
     
    if strcmp(GlobalET, 'y')
        % Eyelink
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %if Eyelink('CheckRecording');
        Eyelink('StartRecording');
        %end
        
        %Eyelink('message',['TRIALID ',num2str(blocks),'_startTrial']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
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
    
end

if strcmp(GlobalET, 'y')
    % Eyelink
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Eyelink('CloseFile');
    WaitSecs(1);
    status = Eyelink('receivefile','',fileEdf);
    Eyelink('shutdown');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end