% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = expDesign(cfg, displayFigs)
    % Creates the sequence of blocks and the events in them
    %
    % The conditions are consecutive static and motion blocks
    % (Gives better results than randomised).
    %
    % EVENTS
    % The numEventsPerBlock should be a multiple of the number of "base"
    % listed in the MOTION_DIRECTIONS and STATIC_DIRECTIONS (4 at the moment).
    %  MOTION_DIRECTIONS = [0 90 180 270];
    %  STATIC_DIRECTIONS = [-1 -1 -1 -1];
    %
    % Pseudorandomization rules:
    % (1) Directions are all present in random orders in `numEventsPerBlock/nDirections`
    % consecutive chunks. This evenly distribute the directions across the
    % block.
    % (2) No same consecutive direction
    %
    %
    % TARGETS
    %
    % Pseudorandomization rules:
    % (1) If there are more than 1 target per block we make sure that they are at least 2
    % events apart.
    % (2) Targets cannot be on the first or last event of a block.
    % (3) Targets can not be present more than `nbRepetitions` - 1 times in the same event
    % position across blocks.
    %
    % Input:
    % - cfg: parameters returned by setParameters
    % - displayFigs: a boolean to decide whether to show the basic design
    % matrix of the design
    %
    % Output:
    % - ExpParameters.designBlockNames = cell array (nr_blocks, 1) with the
    % name for each block
    %
    % - cfg.designDirections = array (nr_blocks, numEventsPerBlock)
    % with the direction to present in a given block
    % - 0 90 180 270 indicate the angle
    % - -1 indicates static
    %
    % - cfg.designSpeeds = array (nr_blocks, numEventsPerBlock) * speedEvent;
    %
    % - cfg.designFixationTargets = array (nr_blocks, numEventsPerBlock)
    % showing for each event if it should be accompanied by a target
    %

    %% Check inputs

    % Set to 1 for a visualtion of the trials design order
    if nargin < 2 || isempty(displayFigs)
        displayFigs = 0;
    end

    % Set variables here for a dummy test of this function
    if nargin < 1 || isempty(cfg)

      displayFigs = 1;

      cfg.design.nbRepetitions = 10;
      cfg.design.nbEventsPerBlock = 12;
      cfg.design.names = {'static'; 'motion'};
      cfg.design.motionDirections = [0 0 180 180];

      cfg.target.maxNbPerBlock = 1;

      % This is only for mock trial of this function, see in `postInitializationSetUp` function how
      % it is calculated during the experiment
      cfg.dot.speedPixPerFrame = 28;
    end

    fprintf('\n\nComputing the design...\n\n');

    % Get the parameter to compute the design with
    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    % Check that
    if mod(nbRepetitions, maxNbPerBlock) ~= 0
         error('number of repetitions must be a multiple of max number of targets');
    end

    [~, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg);



    RANGE_TARGETS = 1:maxNbPerBlock;
    targetPerCondition = repmat(RANGE_TARGETS, 1, nbRepetitions / maxNbPerBlock);

    numTargetsForEachBlock = zeros(1, nbBlocks);
    numTargetsForEachBlock(CONDITON1_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(CONDITON2_INDEX) = shuffle(targetPerCondition);

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

    %% Now we do the easy stuff
    cfg.design.blockNames = assignConditions(cfg);

    cfg.design.nbBlocks = nbBlocks;

    cfg = setDirections(cfg);

    speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;
    cfg.design.speeds = speeds;

    cfg.design.fixationTargets = fixationTargets;

    %% Plot
    diplayDesign(cfg, displayFigs);

    fprintf('\n\n...design computed!\n\n');

end
