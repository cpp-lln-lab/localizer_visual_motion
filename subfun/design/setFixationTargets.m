% (C) Copyright 2021 CPP visual motion localizer developpers

function fixationTargets = setFixationTargets(cfg)

    % Set fixation targets in a matrix of ``nbBlocks`` by ``nbEventsPerBlock`` with some rules:
    % - if there are 2 targets per block we make sure that they are at least 2 events apart
    % - targets cannot be on the first or last event of a block
    % - no less than 1 target per event position in the whole run
    %
    % If the fixation target task is not required, it outputs a matrix with only zeros

    % Get the parameter to compute the design with
    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    % Compute the matrix with the fixation targets if requested, otherwise output will be only zeros
    if sum(contains(cfg.target.type, 'fixation_cross')) ~= 0

        % Check that ...
        if mod(nbRepetitions, maxNbPerBlock) ~= 0
            error('number of repetitions must be a multiple of max number of targets');
        end

        % Get the index of the two conditions
        [~, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

        % Set the range for the possible nb of target per block
        targetRange = 1:maxNbPerBlock;

        % Make a vector of length nb of block per contidion (nbBlock / 2)
        targetPerCondition = repmat(targetRange, 1, nbRepetitions / maxNbPerBlock);

        % Shuffle and assign the number of target per each block (the nb of target event is
        % counterbalanced per condition)
        numTargetsForEachBlock = zeros(1, nbBlocks);
        numTargetsForEachBlock(idxCondition1) = shuffle(targetPerCondition);
        numTargetsForEachBlock(idxCondition2) = shuffle(targetPerCondition);

        %% Give the blocks the names with condition and design the task in each event
        while 1

            % Pre allocate the matrix with zeros
            fixationTargets = zeros(nbBlocks, nbEventsPerBlock);

            % Build the matrix
            for iBlock = 1:nbBlocks

                % Get how many targets in this block
                nbTarget = numTargetsForEachBlock(iBlock);

                % Get the target(s) position and check rule 1 and 2
                chosenPosition = setTargetPositionInSequence( ...
                                                             nbEventsPerBlock, ...
                                                             nbTarget, ...
                                                             [1 nbEventsPerBlock]);

                % Add the target(s) to the final matrix
                fixationTargets(iBlock, chosenPosition) = 1;

            end

            % Check rule 3
            if min(sum(fixationTargets(:, 2:nbEventsPerBlock - 1))) ~= 0
                break
            end

        end

    else

        % Outpu an "empty" matrix in case no fixation task is required
        fixationTargets = zeros(nbBlocks, nbEventsPerBlock);

    end

end
