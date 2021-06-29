% (C) Copyright 2020 CPP visual motion localizer developpers

function saveResponsesAndTriggers(responseEvents, cfg, logFile, triggerString)

    if isfield(responseEvents(1), 'onset') && ~isempty(responseEvents(1).onset)

        for iResp = 1:size(responseEvents, 1)
            responseEvents(iResp).onset = ...
                responseEvents(iResp).onset - cfg.experimentStart;
            responseEvents(iResp).event = 'n/a';
            responseEvents(iResp).block = 'n/a';
            responseEvents(iResp).direction = 'n/a';
            responseEvents(iResp).speed = 'n/a';
            responseEvents(iResp).target = 'n/a';
            if strcmp(responseEvents(iResp).keyName, 't')
                responseEvents(iResp).trial_type = triggerString;
            end
        end

        responseEvents(1).isStim = logFile.isStim;
        responseEvents(1).fileID = logFile.fileID;
        responseEvents(1).extraColumns = logFile.extraColumns;
        saveEventsFile('save', cfg, responseEvents);

    end

end
