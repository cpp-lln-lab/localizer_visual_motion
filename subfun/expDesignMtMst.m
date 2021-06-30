% (C) Copyright 2021 CPP visual motion localizer developpers

function [cfg] = expDesignMtMst(cfg, displayFigs)

    %% Check inputs

    % Set to 1 for a visualtion of the trials design order
    if nargin < 2 || isempty(displayFigs)
        displayFigs = 0;
    end

    % Set variables here for a dummy test of this function
    if nargin < 1 || isempty(cfg)
        error('give me something to work with');
    end

    fprintf('\n\nCreating design.\n\n');

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK, MAX_TARGET_PER_BLOCK] = getDesignInput(cfg);
    [~, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg);

    if mod(NB_REPETITIONS, MAX_TARGET_PER_BLOCK) ~= 0
        error('number of repetitions must be a multiple of max number of targets');
    end

    RANGE_TARGETS = 1:MAX_TARGET_PER_BLOCK;
    targetPerCondition = repmat(RANGE_TARGETS, 1, NB_REPETITIONS / MAX_TARGET_PER_BLOCK);

    numTargetsForEachBlock = zeros(1, NB_BLOCKS);

    if strcmpi(cfg.design.localizer, 'MT_MST') && length(cfg.design.names) == 2
        numTargetsForEachBlock(CONDITON1_INDEX) = shuffle(targetPerCondition);
    end

    numTargetsForEachBlock(CONDITON2_INDEX) = shuffle(targetPerCondition);

    %% Give the blocks the names with condition and design the task in each event
    while 1

        fixationTargets = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);

        for iBlock = 1:NB_BLOCKS

            % Set target
            % - if there are 2 targets per block we make sure that they are at least
            % 2 events apart
            % - targets cannot be on the first or last event of a block
            % - no more than 2 target in the same event order

            nbTarget = numTargetsForEachBlock(iBlock);

            chosenPosition = setTargetPositionInSequence( ...
                                                         NB_EVENTS_PER_BLOCK, ...
                                                         nbTarget, ...
                                                         [1 NB_EVENTS_PER_BLOCK]);

            fixationTargets(iBlock, chosenPosition) = 1;

        end

        % Check rule 3
        if max(sum(fixationTargets)) < NB_REPETITIONS - 1
            break
        end

    end

    %% Now we do the easy stuff
    cfg.design.blockNames = assignConditions(cfg);

    if strcmpi(cfg.design.localizer, 'MT_MST')

        if length(cfg.design.names) == 1

            nbBlocksPerHemifield = (NB_REPETITIONS / 4) * ...
                                                  length(cfg.design.fixationPosition);

        else

            nbBlocksPerHemifield = (NB_REPETITIONS / 2) * ...
                length(cfg.design.fixationPosition);

        end

        cfg.design.blockFixationPosition = repmat(cfg.design.fixationPosition(1), ...
                                                  nbBlocksPerHemifield, ...
                                                  1);

        if length(cfg.design.fixationPosition) == 2

            cfg.design.blockFixationPosition = [cfg.design.blockFixationPosition; ...
                                                repmat(cfg.design.fixationPosition(2), ...
                                                        nbBlocksPerHemifield, ...
                                                        1)];

        end

    end

    cfg.design.nbBlocks = NB_BLOCKS;

    cfg = setDirections(cfg);

    speeds = ones(NB_BLOCKS, NB_EVENTS_PER_BLOCK) * cfg.dot.speedPixPerFrame;
    cfg.design.speeds = speeds;

    cfg.design.fixationTargets = fixationTargets;
