%EYETRACKER
  if use_eyelink

    el=EyelinkInitDefaults(window);

    % Initialization of the connection with the Eyelink Gazetracker.
    if (Eyelink('initialize') ~= 0)
      error('could not init connection to Eyelink');
      return;
    end

    % Open file to record data to
    status=Eyelink('Openfile',edfFile);
    if status~=0
      status
      error('openfile error')
    end

    % Pass the screen resolution to EyeLink
    [width, height]=Screen('WindowSize', screenNumber);
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);

    % Set calibration type.
    Eyelink('command', 'calibration_type = HV5');

    % Get EyeLink version
    [v, vs]=Eyelink('GetTrackerVersion');
    fprintf(fidTime,'Running experiment on a %s tracker.\n', vs );

    % Set event and sample filters (i.e. what will be recorded in the output file)
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');

    % Change camera setup options
    % set pupil Tracking model in camera setup screen
    % no = centroid. yes = ellipse
    Eyelink('command', 'use_ellipse_fitter = no');
    % set sample rate in camera setup screen
    Eyelink('command', 'sample_rate = %d',1000);

    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    % start recording eye position
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    % mark zero-plot time in data file
    Eyelink('Message', 'SYNCTIME');
    TimeEyelink = GetSecs;
    fprintf(fidTime, '%f;%s\n', TimeEyelink, 'Start_Eyelink');
  end
  
  
   % To add message in your file
   if use_eyelink Eyelink('Message','PRE-TEST'); end;
   
   % End with eyelink 
   if use_eyelink
    Eyelink('stoprecording');
    status=Eyelink('closefile');
    if status ~=0
      sprintf('closefile error, status: %d',status)
    end
  end
   
   