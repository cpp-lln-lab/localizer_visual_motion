% (C) Copyright 2020 CPP visual motion localizer developpers

function [CONDITION1_DIRECTIONS, CONDITION2_DIRECTIONS] = getDirectionBaseVectors(cfg)

    % CONSTANTS

    % Set directions for static and motion condition
    CONDITION1_DIRECTIONS = cfg.design.motionDirections;
    CONDITION2_DIRECTIONS = repmat(-1, size(CONDITION1_DIRECTIONS)); % static

    % for for the MT / MST localizer
    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')
        CONDITION1_DIRECTIONS = cfg.design.motionDirections;
        CONDITION2_DIRECTIONS = cfg.design.motionDirections;

        if  length(cfg.design.names) == 2
            CONDITION2_DIRECTIONS = repmat(-1, size(CONDITION1_DIRECTIONS)); % static
        end

    end

end
