function test_suite = test_setFixationTargets %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setFixationTargets_MT()

    isMT = true;
    cfg = getMockConfig(isMT);

    fixationTargets = setFixationTargets(cfg);

    % no target on first and last event of a block
    assertTrue(~any(fixationTargets(:, 1)));
    assertTrue(~any(fixationTargets(:, end)));

    % TODO no target one after the other

    % at least one target for each allowed position
    assertTrue(all(sum(fixationTargets(:, 2:end - 1))) > 0);

    % try when the target are just for the fixation cross
    cfg.target.type = {'speed'};

    fixationTargets = setFixationTargets(cfg);

    assertEqual(fixationTargets, zeros(cfg.design.nbRepetitions * 2, cfg.design.nbEventsPerBlock));

end

function test_setFixationTargets_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    fixationTargets = setFixationTargets(cfg);

    % no target on first and last event of a block
    assertTrue(~any(fixationTargets(:, 1)));
    assertTrue(~any(fixationTargets(:, end)));

    % TODO no target one after the other

    % TODO at least one target for each allowed position
    % assertTrue(all(sum(fixationTargets(:, 2:end - 1))) > 0);

    % try when the target are just for the fixation cross
    cfg.target.type = {'speed'};

    fixationTargets = setFixationTargets(cfg);

    assertEqual(fixationTargets, zeros(cfg.design.nbRepetitions * 2, cfg.design.nbEventsPerBlock));

end
