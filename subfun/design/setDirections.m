function directions = setDirections(cfg)
    %
    % Compute the directions to be displayed
    % in a matrix of size ``nbBlocks`` by ``nbEventsPerBlock``
    %
    % condition1 = 'static';
    % condition2 = 'motion';
    %
    % (C) Copyright 2020 CPP visual motion localizer developpers

    % Get the directions we should work with
    [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg);

    % Get the inputs to compute the experiment design
    [nbRepetitions, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);

    % Get the index of the conditions form the conditions vector
    [~, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    if mod(nbEventsPerBlock, length(directionsCondition2)) ~= 0
        error('Number of events/block not a multiple of number of motion/static direction');
    end

    % Initialize and pre allocate the directions matrix
    directions = zeros(nbBlocks, nbEventsPerBlock);

    % Create a vector for the static condition 1 by ``nbEventsPerBlock``
    nbRepeatsDirectionBaseVector = nbEventsPerBlock / length(directionsCondition1);

    staticDirections = repmat( ...
                              directionsCondition1, ...
                              1, nbRepeatsDirectionBaseVector);

    % Compute the the directions matrix, setting the motion direction orders
    for iMotionBlock = 1:nbRepetitions
        
        % Set motion directions
        directions(idxCondition2(iMotionBlock), :) = ...
        repeatShuffleConditions(directionsCondition2, nbRepeatsDirectionBaseVector);

        if  strcmp(cfg.design.localizer, 'MT') || ...
            strcmp(cfg.design.localizer, 'MT_MST') && length(cfg.design.names) == 2   

                    directions(idxCondition1(iMotionBlock), :) = staticDirections;

        end

    end

end
