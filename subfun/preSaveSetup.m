% (C) Copyright 2020 CPP visual motion localizer developpers

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

    thisEvent = pixToDeg('speedPix', thisEvent, cfg);
    thisEvent.speedDegVA = thisEvent.speedDegVA * cfg.screen.monitorRefresh;

    % Save the events txt logfile
    % we save event by event so we clear this variable every loop
    thisEvent.isStim = logFile.isStim;
    thisEvent.fileID = logFile.fileID;
    thisEvent.extraColumns = logFile.extraColumns;

    varargout = {thisEvent};

end
