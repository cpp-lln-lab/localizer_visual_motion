function [ logFile ] = saveBehOutput(logFile, expParameters, input, varargin)


'BlockNumber', ...
    'EventNumber', ...
    'Direction', ...
    'IsFixationTarget', ...

switch input
    
    case 'open'
        
        
        % Initialize txt logfiles and empty fields for the standard BIDS
        % event file
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
        
        
    case 'save'
        
        % appends to the logfile all the data stored in the structure 
        % first with the standard BIDS data and then any extra things
        for iEvent = 1:size(onset,1)
            
            fprintf(logFile.eventLogFile,'%f\%s\t%f\t',...
                logFile.onset(iEvent,:), ...
                logFile.trial_type(iEvent,:), ...
                logFile.duration(iEvent,:));
            
            for iExtraColumn = 1:numel(varargin)
                data = getfield(logFile, lower(varargin{iExtraColumn}));
                if class(data) == 'char'
                    fprintf(logFile.eventLogFile, '%s\t', data);
                else
                    fprintf(logFile.eventLogFile, '%f\t', data);
                end
            end
            
            fprintf(logFile.eventLogFile, '\n');
        end
        
    case 'close'
        
        % close txt log file
        fclose(logFile.eventLogFile);
        
end