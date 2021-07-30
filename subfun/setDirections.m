% (C) Copyright 2020 CPP visual motion localizer developpers

function cfg = setDirections(cfg)

    [CONDITION1_DIRECTIONS, CONDITION2_DIRECTIONS] = getDirectionBaseVectors(cfg);

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK] = getDesignInput(cfg);

    [~, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg);

    if mod(NB_EVENTS_PER_BLOCK, length(CONDITION1_DIRECTIONS)) ~= 0
        error('Number of events/block not a multiple of number of motion/static direction');
    end

    % initialize
    directions = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);

    % Create a vector for the static condition
    NB_REPEATS_BASE_VECTOR = NB_EVENTS_PER_BLOCK / length(CONDITION2_DIRECTIONS);

    static_directions = repmat( ...
                               CONDITION2_DIRECTIONS, ...
                               1, NB_REPEATS_BASE_VECTOR);

    for iMotionBlock = 1:NB_REPETITIONS

        if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

            % Set motion direction for MT/MST localizer

            %             directions(CONDITON1_INDEX(iMotionBlock), :) = ...
            %                 repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            directions(CONDITON2_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            if length(cfg.design.names) == 2

                directions(CONDITON1_INDEX(iMotionBlock), :) = static_directions;

            end

        else

            % Set motion direction and static order

            directions(CONDITON2_INDEX(iMotionBlock), :) = ...
                repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            directions(CONDITON1_INDEX(iMotionBlock), :) = static_directions;

        end

    end

    cfg.design.directions = directions;

end
