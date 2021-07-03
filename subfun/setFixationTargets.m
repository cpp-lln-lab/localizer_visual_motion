% (C) Copyright 2021 CPP visual motion localizer developpers

function fixationTargets = setFixationTargets(cfg)

  if contains(cfg.target.type, 'fixation_cross')

    % Get the parameter to compute the design with
    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    % Check that
    if mod(nbRepetitions, maxNbPerBlock) ~= 0
        error('number of repetitions must be a multiple of max number of targets');
    end

    [~, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    RANGE_TARGETS = 1:maxNbPerBlock;
    targetPerCondition = repmat(RANGE_TARGETS, 1, nbRepetitions / maxNbPerBlock);

    numTargetsForEachBlock = zeros(1, nbBlocks);
    numTargetsForEachBlock(idxCondition1) = shuffle(targetPerCondition);
    numTargetsForEachBlock(idxCondition2) = shuffle(targetPerCondition);

    %% Give the blocks the names with condition and design the task in each event
    while 1

        fixationTargets = zeros(nbBlocks, nbEventsPerBlock);

        for iBlock = 1:nbBlocks

            % Set target
            % - if there are 2 targets per block we make sure that they are at least
            % 2 events apart
            % - targets cannot be on the first or last event of a block
            % - no more than 2 target in the same event order

            nbTarget = numTargetsForEachBlock(iBlock);

            chosenPosition = setTargetPositionInSequence( ...
                                                         nbEventsPerBlock, ...
                                                         nbTarget, ...
                                                         [1 nbEventsPerBlock]);

            fixationTargets(iBlock, chosenPosition) = 1;

        end

        % Check rule 3
        if max(sum(fixationTargets)) < nbRepetitions - 1
            break
        end

    end

  else

    fixationTargets = zeros(nbBlocks, nbEventsPerBlock);

  end

end
