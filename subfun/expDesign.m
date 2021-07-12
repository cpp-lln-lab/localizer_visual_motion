% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = expDesign(cfg, displayFigs)
    % Creates the sequence of blocks and the events in them
    %
    % The conditions are consecutive static and motion blocks. It gives better results than
    % randomised.
    %
    % EVENTS
    % The ``nbEventsPerBlock`` should be a multiple of the number of motion directions requested in
    % ``motionDirections`` (which should be more than 1) e.g.:
    %  MT localizer: cfg.design.motionDirections = [ 0 90 180 270 ]; % right down left up
    %  MT_MST localizer: cfg.design.motionDirections = [666 -666]; % outward inward
    %
    % Pseudorandomization rules:
    %
    % - Directions:
    % (1) Directions are all presented in random orders in `numEventsPerBlock/nDirections`
    % consecutive chunks. This evenly distribute the directions across the
    % block.
    % (2) No same consecutive direction
    %
    % - Color change detection of the fixation cross:
    % (1) If there are 2 targets per block we make sure that they are at least 2 events apart.
    % (2) Targets cannot be on the first or last event of a block.
    % (3) No less than 1 target per event position in the whole run
    %
    % Input:
    % - cfg: parameters returned by setParameters
    % - displayFigs: a boolean to decide whether to show the basic design
    % matrix of the design
    %
    % Output:
    % - cfg.design.blockNames: cell array (nbBlocks, 1) with the condition name for each block
    % - cfg.design.nbBlocks: integer for th etotal number of blocks in the run
    % - cfg.design.directions: array (nbBlocks, nbEventsPerBlock) with the direction to present in a
    % given event of a block.
    %  - 0 90 180 270 indicate the angle for translational motion direction
    %  - 666 -666 indicate in/out-ward direction in radial motion
    %  - -1 indicates static
    % - cfg.design.speeds: array (nbBlocks, nbEventsPerBlock) * speedEvent indicate the speed of the
    % dots in each event, if different that represents a target [ W I P ]
    % - cfg.design.fixationTargets: array (nbBlocks, numEventsPerBlock) showing for each event if it
    % should be accompanied by a target

    %% Check inputs

    % Set to 1 for a visualtion of the trials design order
    if nargin < 2 || isempty(displayFigs)
        displayFigs = 0;
    end

    % Set variables here for a dummy test of this function
    if nargin < 1 || isempty(cfg)

        displayFigs = 1;

        % Design

        % ``nbRepetitions``:
        % 2 conditions [`cfg.design.names`] and 10 repetitions [`cfg.design.nbRepetitions`]
        % means 20 blocks

        cfg.design.localizer = 'MT'; % 'MT' ; 'MT_MST'

        cfg.design.nbRepetitions = 10;
        cfg.design.names = {'motion'};
        cfg.design.nbEventsPerBlock = 12;

        % MT loc
        cfg.design.motionDirections = [0 180]; % choices: [ 0 90 180 270 ] right down left up

        % MT_MST loc
        if strcmpi(cfg.design.localizer, 'MT_MST')

            cfg.design.motionDirections = [666 -666]; % choices [666 -666] outward inward
            cfg.design.fixationPosition = {'fixation_left'; 'fixation_right'};

        end

        % Task

        cfg.target.type = {'fixation_cross', 'speed'};
        cfg.target.maxNbPerBlock = 2;

        % This is only for a dummy trial of this function.
        % See in `postInitializationSetUp` how it is calculated during the experiment
        cfg.dot.speedPixPerFrame = 28;

    end

    fprintf('\n\nComputing the design...\n\n');

    %% Stimuli design

    % Computer a vector [nbBlocks x 1] with the order of the conditions to present
    cfg.design.blockNames = setBlocksConditions(cfg);

    % Get the nb of blocks
    [~, ~, ~, cfg.design.nbBlocks] = getDesignInput(cfg);

    % Compute a matrix [nbBlocks x nbEventsPerBlock]
    cfg.design.directions = setDirections(cfg);

    %% Task(s) design

    % Compute a matrix [nbBlocks x nbEventsPerBlock] with
    cfg.design.fixationTargets = setFixationTargets(cfg);

    % Compute a matrix [nbBlocks x nbEventsPerBlock] with the dots speeds (target speed will be
    % different form the base one)
    cfg.design.speeds = setSpeedTargets(cfg);

    %% Plot a visual representation of the design
    diplayDesign(cfg, displayFigs);

    fprintf('\n\n...design computed!\n\n');

end
