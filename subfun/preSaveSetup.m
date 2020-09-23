function varargout = preSaveSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to prepare structures before saving

    [thisEvent, thisFixation, iBlock, iEvent, duration, onset, cfg, logFile] = ...
        deal(varargin{:});

    thisEvent.event = iEvent;
    thisEvent.block = iBlock;
    thisEvent.keyName = 'n/a';
    thisEvent.duration = duration;
    thisEvent.onset = onset - cfg.experimentStart;
    thisEvent.fixationPosition = thisFixation.fixation.xDisplacement;
    thisEvent.aperturePosition = cfg.aperture.xPos * sign(cfg.aperture.xPosPix);

    % % this value should be in degrees / second in the log file
    % % highlights that the way speed is passed around could be
    % % simplified.
    % %
    % thisEvent.speed
    % %

    % Save the events txt logfile
    % we save event by event so we clear this variable every loop
    thisEvent.fileID = logFile.fileID;
    thisEvent.extraColumns = logFile.extraColumns;

    varargout = {thisEvent};

end
