dummymode=0;       % set to 1 to initialize in dummymode

% STEP 1
% % %     % Open a graphics window on the main screen
% % %     screenNumber=max(Screen('Screens'));
% % %     [window, wRect]=Screen('OpenWindow', screenNumber);


% STEP 2

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(window);

% STEP 3

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end

[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% % %     % make sure that we get event data from the Eyelink
% % % %         Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
% % %     Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
% % %     Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');

% open file for recording data
edfFile='demo.edf';
Eyelink('Openfile', edfFile);

% STEP 4

% Do setup and calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% do a final check of calibration using driftcorrection
% You have to hit esc before return.
EyelinkDoDriftCorrection(el);

% % % % do a final check of calibration using driftcorrection
% % % success=EyelinkDoDriftCorrection(el);
% % % if success~=1
% % %     cleanup;
% % %     return;
% % % end

% STEP 5

% Start recording eye position
Eyelink('StartRecording');
% record a few samples before we actually start displaying
WaitSecs(0.5);

% STEP 6

% % % start stimulation

% mark zero-plot time in data file
Eyelink('Message', 'SYNCTIME');
% wait a while to record a bunch of samples
WaitSecs(3);

% % % % Check recording status, stop display if error
% % % error=Eyelink('checkrecording');
% % % if(error~=0)
% % %     break;
% % % end

% STEP 7 remove image

% % % end stimulation

% mark end stimulation removal time in data file
Eyelink('Message', 'ENDTIME');
WaitSecs(0.5);
Eyelink('Message', 'TRIAL_END');

% STEP 8

% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('StopRecording');
Eyelink('CloseFile');

% % % % download data file
% % % try
% % %     fprintf('Receiving data file ''%s''\n', edfFile );
% % %     status=Eyelink('ReceiveFile');
% % %     if status > 0
% % %         fprintf('ReceiveFile status %d\n', status);
% % %     end
% % %     if 2==exist(edfFile, 'file')
% % %         fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
% % %     end
% % % catch rdf
% % %     fprintf('Problem receiving data file ''%s''\n', edfFile );
% % %     rdf;
% % % end

% Shutdown Eyelink:
Eyelink('Shutdown');
