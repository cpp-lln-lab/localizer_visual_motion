function fixationTargets = setFixationTargets(cfg)
    %
    % fixationTargets = setFixationTargets(cfg)
    %
    % Set fixation targets in a matrix of ``nbBlocks`` by ``nbEventsPerBlock`` with some rules:
    %
    % - if there are 2 targets per block we make sure that they are at least 2 events apart
    % - targets cannot be on the first or last event of a block
    % - no less than 1 target per event position in the whole run
    %
    % If the fixation target task is not required, it outputs a matrix with only zeros
    %
    %
    % (C) Copyright 2021 CPP visual motion localizer developers

    % Get the parameter to compute the design with
    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    % Compute the matrix with the fixation targets if requested

    % Output an "empty" matrix in case no fixation task is required
    if ~ismember('fixation_cross', cfg.target.type)

        fixationTargets = zeros(nbBlocks, nbEventsPerBlock);
        return

    else % Compute the matrix with the fixation targets if requested

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

        if  strcmp(cfg.design.localizer, 'MT') || ...
                strcmp(cfg.design.localizer, 'MT_MST') && length(cfg.design.names) == 2

            numTargetsForEachBlock(idxCondition1) = shuffle(targetPerCondition);

        end

        numTargetsForEachBlock(idxCondition2) = shuffle(targetPerCondition);

        %% Give the blocks the names with condition and design the task in each event
        while 1

            % Pre allocate the matrix with zeros
            fixationTargets = zeros(nbBlocks, nbEventsPerBlock);

            % Build the matrix
            for iBlock = 1:nbBlocks

                % Get how many targets in this block
                nbTarget = numTargetsForEachBlock(iBlock);

                switch cfg.design.localizer

                    case 'MT'

                        % Get the target(s) position and check rule 1 and 2
                        chosenPosition = setTargetPositionInSequence( ...
                                                                     nbEventsPerBlock, ...
                                                                     nbTarget, ...
                                                                     [1 nbEventsPerBlock]);

                    case 'MT_MST'

                        % Get the target(s) position and check rule 1 and 2
                        % Since an event composed of inward+outward is divided in subevents, we
                        % avoid the first and last two positions
                        chosenPosition = setTargetPositionInSequence( ...
                                                                     nbEventsPerBlock, ...
                                                                     nbTarget, ...
                                                                     [1:2 nbEventsPerBlock - ...
                                                                      1:nbEventsPerBlock]);

                end

                % Add the target(s) to the final matrix
                fixationTargets(iBlock, chosenPosition) = 1;

            end

            switch cfg.design.localizer

                case 'MT'

                    % Check rule 3
                    if min(sum(fixationTargets(:, 2:nbEventsPerBlock - 1))) ~= 0
                        break
                    end

                case 'MT_MST'

                    mergedSubEvents = zeros(size(fixationTargets, 1), size(fixationTargets, 2) / 2);

                    for i = 1:size(fixationTargets, 1)
                        mergedSubEvents(i, :) = squeeze(sum( ...
                                                            reshape(fixationTargets(i, :), ...
                                                                    1, ...
                                                                    2, ...
                                                                    []), ...
                                                            2))';
                    end

                    % Check rule 3
                    if min(sum(mergedSubEvents(:, 2:(nbEventsPerBlock / 2) - 1))) ~= 0
                        break
                    end

            end

        end

    end

end
