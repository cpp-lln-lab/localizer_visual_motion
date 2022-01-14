function [cfg] = expDesign(cfg)
    %
    % Creates the sequence of blocks and the events in them
    %
    % The conditions are consecutive static and motion blocks.
    % It gives better results than randomised.
    %
    % It can be run as a stand alone without inputs and display a visual example of the
    % possible design. See `getMockConfig` to set up the mock configuration.
    %
    % It computes the directions to display and the task(s), at the moment:
    % (1) detection of change in the color of the fixation target
    % (2) detection of different speed of the moving dots
    %     [ W I P - if selected as a task it will give the same null output
    %     as if not selected ie no difference in speed ]
    %
    % EVENTS
    % The ``nbEventsPerBlock`` should be a multiple of the number of motion directions requested in
    % ``motionDirections`` (which should be more than 1) e.g.:
    %
    %  MT localizer: ``cfg.design.motionDirections = [ 0 90 180 270 ]; % right down left up``
    %  MT_MST localizer: ``cfg.design.motionDirections = [666 -666]; % outward inward``
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
    % - cfg.design.directions: array (nbBlocks, nbEventsPerBlock) with the direction
    %                          to present in a given event of a block.
    % - cfg.design.blockFixationPosition: [MT_MST] array (nbBlocks, 1)
    %                                     with the position in the hemifiled
    %                                     where to show the fixation cross
    %  - 0 90 180 270 indicate the angle for translational motion direction
    %  - 666 -666     indicate in/out-ward direction in radial motion
    %  - -1           indicates static
    % - cfg.design.speeds: array (nbBlocks, nbEventsPerBlock) indicate the dots speed
    %                 in each event, the target is represented by a higher/lower value
    % - cfg.design.fixationTargets: array (nbBlocks, numEventsPerBlock) showing
    %                               for each event if it should be accompanied by a target
    %
    %
    % (C) Copyright 2020 CPP visual motion localizer developpers

    %% Check inputs

    % Do not display any figure during the experiment
    displayFigs = 0;

    if nargin < 1 || isempty(cfg)

        % ``true`` for MT+ translational localizer
        % ``false`` for MT/MST localizer
        isMT = false;

        % Get mock inputs to run this function as a stand alone and get a flavour of how the design
        % looks like given certain inputs. Open this function to set different inputs.
        cfg = getMockConfig(isMT);

        % Get the computed design on a visual representation
        displayFigs = 1;

        % make sure we got access to all the required functions and inputs
        run('../../initEnv.m');

    end

    fprintf('\n\nComputing the design...\n\n');

    %% Stimuli design

    % Computer a vector [nbBlocks x 1] with the order of the conditions to present
    cfg.design.blockNames = setBlocksConditions(cfg);

    % Get the nb of blocks
    [~, ~, ~, cfg.design.nbBlocks] = getDesignInput(cfg);

    % Compute a matrix [nbBlocks x nbEventsPerBlock]
    cfg.design.directions = setDirections(cfg);

    % Compute the fixation position (left/right hemifield) for MT/MST
    cfg.design.blockFixationPosition = setFixationPosition(cfg);

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
