% (C) Copyright 2020 CPP visual motion localizer developpers

function directions = setDirections(cfg)

    % Compute the directions to be displayed in a matric of size ``nbBlocks`` by ``nbEventsPerBlock``
    %
    % condition1 = 'static';
    % condition2 = 'motion';

    [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg);

    [nbRepetitions, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);

    [~, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    if mod(nbEventsPerBlock, length(directionsCondition2)) ~= 0
        error('Number of events/block not a multiple of number of motion/static direction');
    end

    % initialize
    directions = zeros(nbBlocks, nbEventsPerBlock);

    % Create a vector for the static condition
    nbRepeatsDirectionBaseVector = nbEventsPerBlock / length(directionsCondition1);

    staticDirections = repmat( ...
                              directionsCondition1, ...
                              1, nbRepeatsDirectionBaseVector);

    for iMotionBlock = 1:nbRepetitions

        if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

            % Set motion direction for MT/MST localizer

            %             directions(CONDITON1_INDEX(iMotionBlock), :) = ...
            %                 repeatShuffleConditions(CONDITION1_DIRECTIONS, NB_REPEATS_BASE_VECTOR);

            directions(idxCondition2(iMotionBlock), :) = ...
                repeatShuffleConditions(directionsCondition2, nbRepeatsDirectionBaseVector);

            if length(cfg.design.names) == 2

                directions(idxCondition1(iMotionBlock), :) = staticDirections;

            end

        else

            % Set motion direction and static order

            directions(idxCondition2(iMotionBlock), :) = ...
                repeatShuffleConditions(directionsCondition2, nbRepeatsDirectionBaseVector);

            directions(idxCondition1(iMotionBlock), :) = staticDirections;

        end

    end

end
