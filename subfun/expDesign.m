function [cfg] = expDesign(cfg, displayFigs)
    % Creates the sequence of blocks and the events in them
    %
    % The conditions are consecutive static and motion blocks
    % (Gives better results than randomised).
    %
    % Style guide: constants are in SNAKE_UPPER_CASE
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
    % (1) If there are 2 targets per block we make sure that they are at least 2
    % events apart.
    % (2) Targets cannot be on the first or last event of a block.
    % (3) Targets can not be present more than 2 times in the same event
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
        %         cfg.design.motionType = 'translation';
        cfg.design.motionType = 'radial';
        cfg.design.names = {'static'; 'motion'};
        cfg.design.nbRepetitions = 4;
        cfg.design.nbEventsPerBlock = 12;
        cfg.dot.speedPixPerFrame = 4;
        cfg.target.maxNbPerBlock = 2;
        displayFigs = 1;
    end

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK, MAX_TARGET_PER_BLOCK] = getInput(cfg);
    [~, STATIC_INDEX, MOTION_INDEX] = assignConditions(cfg);

    RANGE_TARGETS = [1 MAX_TARGET_PER_BLOCK];
    targetPerCondition = repmat(RANGE_TARGETS, 1, NB_REPETITIONS / 2);

    numTargetsForEachBlock = zeros(1, NB_BLOCKS);
    numTargetsForEachBlock(STATIC_INDEX) = shuffle(targetPerCondition);
    numTargetsForEachBlock(MOTION_INDEX) = shuffle(targetPerCondition);

    %% Give the blocks the names with condition and design the task in each event
    while 1

        fixationTargets = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);

        for iBlock = 1:NB_BLOCKS

            % Set target
            % - if there are 2 targets per block we make sure that they are at least
            % 2 events apart
            % - targets cannot be on the first or last event of a block
            % - no more than 2 target in the same event order

            chosenTarget = [];

            tmpTarget = numTargetsForEachBlock(iBlock);

            switch tmpTarget

                case 1

                    chosenTarget = randsample(2:NB_EVENTS_PER_BLOCK - 1, tmpTarget, false);

                case 2

                    targetDifference = 0;

                    while any(targetDifference <= 2)
                        chosenTarget = randsample(2:NB_EVENTS_PER_BLOCK - 1, tmpTarget, false);
                        targetDifference = diff(chosenTarget);
                    end

            end

            fixationTargets(iBlock, chosenTarget) = 1;

        end

        % Check rule 3
        if max(sum(fixationTargets)) < 3
            break
        end

    end

    %% Now we do the easy stuff
    cfg.design.blockNames = assignConditions(cfg);

    cfg.design.nbBlocks = NB_BLOCKS;

    cfg = setDirections(cfg);

    speeds = ones(NB_BLOCKS, NB_EVENTS_PER_BLOCK) * cfg.dot.speedPixPerFrame;
    cfg.design.speeds = speeds;

    cfg.design.fixationTargets = fixationTargets;

    %% Plot
    diplayDesign(cfg, displayFigs);

end

function cfg = setDirections(cfg)

    [MOTION_DIRECTIONS, STATIC_DIRECTIONS] = getDirectionBaseVectors(cfg);

    [NB_BLOCKS, NB_REPETITIONS, NB_EVENTS_PER_BLOCK] = getInput(cfg);

    [~, STATIC_INDEX, MOTION_INDEX] = assignConditions(cfg);

    if mod(NB_EVENTS_PER_BLOCK, length(MOTION_DIRECTIONS)) ~= 0
        error('Number of events/block not a multiple of number of motion/static direction');
    end

    % initialize
    directions = zeros(NB_BLOCKS, NB_EVENTS_PER_BLOCK);

    % Create a vector for the static condition
    static_directions = repmat( ...
        STATIC_DIRECTIONS, ...
        1, NB_EVENTS_PER_BLOCK / length(STATIC_DIRECTIONS));

    for iMotionBlock = 1:NB_REPETITIONS

        % Check that we never have twice the same direction
        while 1
            tmp = [ ...
                shuffle(MOTION_DIRECTIONS), ...
                shuffle(MOTION_DIRECTIONS), ...
                shuffle(MOTION_DIRECTIONS)];

            if ~any(diff(tmp, [], 2) == 0)
                break
            end
        end

        % Set motion direction and static order
        directions(MOTION_INDEX(iMotionBlock), :) = tmp;
        directions(STATIC_INDEX(iMotionBlock), :) = static_directions;

    end

    cfg.design.directions = directions;

end

function [MOTION_DIRECTIONS, STATIC_DIRECTIONS] = getDirectionBaseVectors(cfg)

    % CONSTANTS
    % Set directions for static and motion condition

    STATIC_DIRECTIONS = [-1 -1 -1 -1];

    switch cfg.design.motionType
        case 'translation'
            MOTION_DIRECTIONS = [0 90 180 270];
        case 'radial'
            STATIC_DIRECTIONS = [666 -666 666 -666];
            MOTION_DIRECTIONS = [666 -666 666 -666];
    end

end

function [nbBlocks, nbRepet, nbEventsBlock, maxTargBlock] = getInput(cfg)
    nbRepet = cfg.design.nbRepetitions;
    nbEventsBlock = cfg.design.nbEventsPerBlock;
    maxTargBlock = cfg.target.maxNbPerBlock;
    nbBlocks = length(cfg.design.names) * nbRepet;
end

function [condition, STATIC_INDEX, MOTION_INDEX] = assignConditions(cfg)

    [~, nbRepet] = getInput(cfg);

    condition = repmat(cfg.design.names, nbRepet, 1);

    % Get the index of each condition
    STATIC_INDEX = find(strcmp(condition, 'static'));
    MOTION_INDEX = find(strcmp(condition, 'motion'));

end

function shuffled = shuffle(unshuffled)
    % in case PTB is not in the path
    try
        shuffled = Shuffle(unshuffled);
    catch
        shuffled = unshuffled(randperm(length(unshuffled)));
    end
end

function diplayDesign(cfg, displayFigs)

    %% Visualize the design matrix
    if displayFigs

        close all;

        figure(1);

        % Shows blocks (static and motion) and events (motion direction) order
        directions = cfg.design.directions;
        directions(directions == -1) = -90;

        subplot(3, 1, 1);
        imagesc(directions);

        labelAxesBlock();

        caxis([-90 - 37, 270 + 37]);
        myColorMap = lines(5);
        colormap(myColorMap);

        title('Block (static and motion) & Events (motion direction)');

        % Shows the fixation targets design in each event (1 or 0)
        fixationTargets = cfg.design.fixationTargets;

        subplot(3, 1, 2);
        imagesc(fixationTargets);
        labelAxesBlock();
        title('Fixation Targets design');
        colormap(gray);

        % Shows the fixation targets position distribution in the block across
        % the experimet
        [~, itargetPosition] = find(fixationTargets == 1);

        subplot(3, 1, 3);
        hist(itargetPosition);
        labelAxesFreq();
        title('Fixation Targets position distribution');

        figure(2);

        [motionDirections] = getDirectionBaseVectors(cfg);
        motionDirections = unique(motionDirections);

        for iMotion = 1:length(motionDirections)

            [~, position] = find(directions == motionDirections(iMotion));

            subplot(2, 2, iMotion);
            hist(position);
            scaleAxes();
            labelAxesFreq();
            title(num2str(motionDirections(iMotion)));

        end

    end

end

function labelAxesBlock()
    % an old viking saying because they really cared about their axes
    ylabel('Block seq.', 'Fontsize', 8);
    xlabel('Events', 'Fontsize', 8);
end

function labelAxesFreq()
    % an old viking saying because they really cared about their axes
    ylabel('Number of targets', 'Fontsize', 8);
    xlabel('Events', 'Fontsize', 8);
end

function scaleAxes()
    xlim([1 12]);
    ylim([0 5]);
end
