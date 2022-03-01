function [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg)
    %
    % [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg)
    %
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    % Set directions for static and motion condition

    % condition1 = 'static';
    % condition2 = 'motion';

    directionsCondition1 = repmat(-1, size(cfg.design.motionDirections));

    directionsCondition2 = cfg.design.motionDirections;

end
