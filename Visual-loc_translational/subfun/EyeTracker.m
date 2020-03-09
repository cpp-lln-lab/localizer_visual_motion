function [ el ] = EyeTracker(Cfg, ExpParameters, subjectName, sessionNumber, runNumber, input)

switch input
    
    case 'Calibration'
        
        % STEP 2
        % Provide Eyelink with details about the graphics environment
        % and perform some initializations. The information is returned
        % in a structure that also contains useful defaults
        % and control codes (e.g. tracker state bit and Eyelink key values).
        el = EyelinkInitDefaults(Cfg.win);
        
        % STEP 3
        % Initialization of the connection with the Eyelink Gazetracker.
        % exit program if this fails.
        if ~EyelinkInit(dummymode)
            fprintf('Eyelink Init aborted.\n');
            cleanup;  % cleanup function
            return;
        end
        
        [el.v, el.vs] = Eyelink('GetTrackerVersion');
        fprintf('Running experiment on a ''%s'' tracker.\n', vs );
        
        % open file for recording data
        
        if ~exist('eyetracker','dir')
            mkdir('eyetracker')
        end
        
        edfFile = fullfile('eyetracker', ...
            ['sub-', subjectName, ...
            '_ses-', sessionNumber, ...
            '_task-', ExpParameters.task, ...
            '_run-', runNumber ...
            '_eyetracker.edf']);
        
        Eyelink('Openfile', edfFile);
        
        % STEP 4
        % Do setup and calibrate the eye tracker
        EyelinkDoTrackerSetup(el);
        
        % do a final check of calibration using driftcorrection
        % You have to hit esc before return.
        EyelinkDoDriftCorrection(el);
        
    case 'StartRecording'
        
        % STEP 5
        % Start recording eye position
        Eyelink('StartRecording');
        % % % % record a few samples before we actually start displaying
        % % % WaitSecs(0.5);
        
    case 'Sync'
        
        % STEP 6 - stimulation starts
        % mark zero-plot time in data file
        
        % % % % MAY CONSIDER TO PUT THE CONDITION NAME
        Eyelink('Message', 'SYNCTIME');
        % % %
        
        % % % % wait a while to record a bunch of samples
        % % % WaitSecs(3);
        
        % Check recording status, stop display if error
        checkrec=Eyelink('checkrecording');
        if(checkrec~=0)
            fprintf('\nEyelink is not recording.\n\n');
            %             break;
        end
        
    case 'TrialEnd'
        
        % STEP 7 remove image - stimulation is over
        % mark end stimulation removal time in data file
        Eyelink('Message', 'ENDTIME');
        WaitSecs(0.5);
        Eyelink('Message', 'TRIAL_END');
        
    case 'StopRecordings'
        
        % STEP 8
        % finish up: stop recording eye-movements,
        % close graphics window, close data file and shut down tracker
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        
    case 'Shutdown'
        
        % Shutdown Eyelink:
        Eyelink('Shutdown');
        
end