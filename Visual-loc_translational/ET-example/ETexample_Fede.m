% Normally there is a variable called "dummymode" to do the same thing, but
% it causes problem on my mac, so I use this "RunEyelinkCode" variable and
% use an if statement when I want to use it.
RunEyelinkCode = 0;     % Set to 1 when you are testing; 0 when you are running on the computer


% EYELINK CODE
if RunEyelinkCode
dummymode = 0;          %% DUMMY MODE SHOULD BE ZERO WHEN TESTING
prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
dlg_title = 'Create EDF file';
num_lines= 1;
def     = {'DEMO'};
answer  = inputdlg(prompt,dlg_title,num_lines,def);
%edfFile= 'DEMO.EDF'
edfFile = answer{1};
fprintf('EDFFile: %s\n', edfFile );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% START USING THE EYELINK AFTER OPENING A NEW WINDOW/SCREEN USING
% PSYCHTOOLBOX.
% The following prepares the initial setup, and calibration
%% EYELINK
if RunEyelinkCode

el=EyelinkInitDefaults(mainWindow);
if ~EyelinkInit(dummymode)
fprintf('Eyelink Init aborted.\n');
cleanup;  % cleanup function
return;
end

% the following code is used to check the version of the eye tracker
% and version of the host software
sw_version = 0;

[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% open file to record data to
i = Eyelink('Openfile', edfFile);
if i~=0
fprintf('Cannot create EDF file ''%s'' ', edffilename);
Eyelink( 'Shutdown');
Screen('CloseAll');
return;
end

Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
[width, height]=Screen('WindowSize', screenid);

%% SET UP EYELINK CONFIGURATION
% Setting the proper recording resolution, proper calibration type,
% as well as the data file content;
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
% set calibration type.
Eyelink('command', 'calibration_type = HV9');
% set parser (conservative saccade thresholds)

% set EDF file contents using the file_sample_data and
% file-event_filter commands
% set link data thtough link_sample_data and link_event_filter
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

% check the software version
% add "HTARGET" to record possible target data for EyeLink Remote
if sw_version >=4
Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

% allow to use the big button on the eyelink gamepad to accept the
% calibration/drift correction target
Eyelink('command', 'button_function 5 "accept_target_fixation"');


% make sure we're still connected.
if Eyelink('IsConnected')~=1 && dummymode == 0
fprintf('not connected, clean up\n');
Eyelink( 'Shutdown');
Screen('CloseAll');
return;
end

%% Calibrate the eye tracker
% setup the proper calibration foreground and background colors
el.backgroundcolour = [125 125 125] ;
el.calibrationtargetcolour = [255 255 255] ;

% parameters are in frequency, volume, and duration
% set the second value in each line to 0 to turn off the sound
el.cal_target_beep=[600 0.5 0.05];
el.drift_correction_target_beep=[600 0.5 0.05];
el.calibration_failed_beep=[400 0.5 0.25];
el.calibration_success_beep=[800 0.5 0.25];
el.drift_correction_failed_beep=[400 0.5 0.25];
el.drift_correction_success_beep=[800 0.5 0.25];

% you must call this function to apply the changes from above
EyelinkUpdateDefaults(el);

% Hide the mouse cursor;
Screen('HideCursorHelper', mainWindow);
EyelinkDoTrackerSetup(el);

end  



%% EYELINK
if RunEyelinkCode

%Eyelink('Message', 'TRIALID %d', trial);
% This supplies the title at the bottom of the eyetracker display
Eyelink('command', 'record_status_message "TRIAL %d/%d "', trial, 3);
% Before recording, we place reference graphics on the host display
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen 0')
Eyelink('command', 'draw_box %d %d %d %d 15', width/2-50, height/2-50, width/2+50, height/2+50);
% TO BE CORRECTED @@@@@@@@@@@@@@@@@@@@@@@@@

% Do a drift correction at the beginning of each trial
% Performing drift correction (checking) is optional for
% EyeLink 1000 eye trackers.
%         EyelinkDoDriftCorrection(el); %pour s'assurer que le participant
%         regarde bien la croix de fixation.

% start recording eye position (preceded by a short pause so that
% the tracker can finish the mode transition)
% The paramerters for the 'StartRecording' call controls the
% file_samples, file_events, link_samples, link_events availability
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);


%% Eyelink start recording
Eyelink('StartRecording');
WaitSecs(0.05); % SET HOW MUCH TIME YOU WANT BEFORE THE SCRIPT CONTINUES TO YOUR STIMULI

%Message to mark the trial onset
Eyelink('Message', 'SYNCTIME'); % to mark the beginning of the trial

end      


%% EYELINK  - STOP RECORDING
if RunEyelinkCode

	Eyelink('Message', 'BLANK_SCREEN');
	% adds 100 msec of data to catch final events
	WaitSecs(0.1);
	% stop the recording of eye-movements for the current trial
	Eyelink('StopRecording');
end


%% EYE TRACKER - SHUTDOWN [ SHOULD BE AT THE END OF YOUR SCRIPT]
% STEP 9
% close the eye tracker and window
if RunEyelinkCode
Eyelink('ShutDown');
end