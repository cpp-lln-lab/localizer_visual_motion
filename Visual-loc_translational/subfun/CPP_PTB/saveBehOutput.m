function [ logFile ] = saveBehOutput(logFile, expParameters, input, varargin)


'BlockNumber', ...
    'EventNumber', ...
    'Direction', ...
    'IsFixationTarget', ...

switch input
    
    case 'open'
        
        
        % Initialize txt logfiles
        logFile.eventLogFile = fopen(...
            fullfile(expParameters.outputDir, expParameters.fileName.events), ...
            'w');
        
        logFile.onset = [];
        logFile.trial_type = [];
        logFile.duration = [];
        
        % print the basic BIDS columns
        fprintf(eventLogFile, '%s\t%s\t%s\t', 'onset', 'trial_type', 'duration');
        
        % print any extra column specified by the user
        % also prepare an empty field in the structure to collect data
        % for those
        for iExtraColumn = 1:numel(varargin)
            fprintf(logFile.eventLogFile,'%s\t', lower(varargin{iExtraColumn}));
            logFile = setfield(logFile, lower(varargin{iExtraColumn}));
        end
        
        % next line so we start printing at the right place
        fprintf(logFile.eventLogFile, '\n');
        
            'Direction', ...
            'IsFixationTarget', ...
            'Speed', ...
            'Onset', ...
            'End', ...
            'Duration');

        
    case 'save Events'
        
        % Event txt_Logfile
        fprintf(logFile.EventTxtLogFile,'%12.0f %12.0f %12.0f %18.0f %12.2f %12.5f %12.5f %12.5f \n',...
            iBlock, ...
            iEventsPerBlock, ...
            logFile.iEventDirection, ...
            logFile.iEventIsFixationTarget, ...
            logFile.iEventSpeed, ...
            logFile.eventOnsets(iBlock, iEventsPerBlock), ...
            logFile.eventEnds(iBlock, iEventsPerBlock), ...
            logFile.eventDurations(iBlock, iEventsPerBlock));
        
    case 'close'
        
        % close txt log files
        fclose(logFile.BlockTxtLogFile);
        fclose(logFile.EventTxtLogFile);
        fclose(logFile.ResponsesTxtLogFile);
        
end