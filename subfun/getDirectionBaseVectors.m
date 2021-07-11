% (C) Copyright 2020 CPP visual motion localizer developpers

function [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg)

    % condition1 = 'static';
    % condition2 = 'motion';

    % Set directions for static and motion condition
    directionsCondition1 = repmat(-1, size(cfg.design.motionDirections));
    directionsCondition2 = cfg.design.motionDirections;

    % For the MT / MST localizer
    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

        directionsCondition1 = cfg.design.motionDirections;

        if  length(cfg.design.names) == 2

            directionsCondition1 = repmat(-1, size(cfg.design.motionDirections)); % static

        end

    end

end
