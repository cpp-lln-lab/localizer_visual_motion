function test_suite = test_expDesign %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_exDesignBasic()

    initEnv();

    cfg.design.motionType = 'translation';
    cfg.design.motionDirections = [0 0 180 180];
    cfg.design.names = {'static'; 'motion'};
    cfg.design.nbRepetitions = 6;
    cfg.design.nbEventsPerBlock = 12;
    cfg.dot.speedPixPerFrame = 4;
    cfg.target.maxNbPerBlock = 3;
    displayFigs = 0;

    [cfg] = expDesign(cfg, displayFigs);

    % make sure we don't have the same directions one after the other
    directions = cfg.design.directions(strcmp(cfg.design.blockNames, 'motion'), :);
    repeatedDirections = all(diff(directions, [], 2) == 0);
    assertTrue(all(repeatedDirections == 0));

    % make sure that we have the right number of blocks of the right length
    assertTrue(all(size(cfg.design.directions) == [ ...
                                                   cfg.design.nbRepetitions * ...
                                                   numel(cfg.design.names), ...
                                                   cfg.design.nbEventsPerBlock]));

    %  check that we do not have more than the required number of targets per
    %  block
    assertTrue(all(sum(cfg.design.fixationTargets, 2) <= cfg.target.maxNbPerBlock));

    % make sure that targets are not presented too often in the same position
    assertTrue(all(sum(cfg.design.fixationTargets) < cfg.design.nbRepetitions - 1));

end

function test_exDesignBasicOtherSetUp()

    initEnv();

    cfg.design.motionType = 'translation';
    cfg.design.motionDirections = [0 90 180 270];
    cfg.design.names = {'static'; 'motion'};
    cfg.design.nbRepetitions = 9;
    cfg.design.nbEventsPerBlock = 8;
    cfg.dot.speedPixPerFrame = 4;
    cfg.target.maxNbPerBlock = 3;
    displayFigs = 0;

    [cfg] = expDesign(cfg, displayFigs);

    % make sure we don't have the same directions one after the other
    directions = cfg.design.directions(strcmp(cfg.design.blockNames, 'motion'), :);
    repeatedDirections = all(diff(directions, [], 2) == 0);
    assertTrue(all(repeatedDirections == 0));

    % make sure that we have the right number of blocks of the right length
    assertTrue(all(size(cfg.design.directions) == [ ...
                                                   cfg.design.nbRepetitions * ...
                                                   numel(cfg.design.names), ...
                                                   cfg.design.nbEventsPerBlock]));

    %  check that we do not have more than the required number of targets per
    %  block
    assertTrue(all(sum(cfg.design.fixationTargets, 2) <= cfg.target.maxNbPerBlock));

    % make sure that targets are not presented too often in the same position
    assertTrue(all(sum(cfg.design.fixationTargets) < cfg.design.nbRepetitions - 1));

end
