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
    numTargetsForEachBlock(CONDITON1_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(CONDITON2_INDEX) = shuffle(targetPerCondition);