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
    %
    % - Directions:
    % (1) Directions are all present in random orders in `numEventsPerBlock/nDirections`
    % consecutive chunks. This evenly distribute the directions across the
    % block.
    % (2) No same consecutive direction
    %
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

        cfg.design.localizer = 'MT';
        % Repetition per condition:
        % 2 conditions [`cfg.design.names`] and 10 repetitions [`cfg.design.nbRepetitions`]
        % means 20 blocks
        cfg.design.nbRepetitions = 10;
        cfg.design.names = {'static'; 'motion'};
        cfg.design.nbEventsPerBlock = 12;
        cfg.design.motionDirections = [0 180];

        cfg.target.type = {'fixation_cross', 'speed'};
        cfg.target.maxNbPerBlock = 2;

        % This is only for dummy trial of this function.
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
