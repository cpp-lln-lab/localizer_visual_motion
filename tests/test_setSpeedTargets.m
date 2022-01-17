function test_suite = test_setSpeedTargets %#ok<*STOUT>
    % (C) Copyright 2021 CPP visual motion localizer developpers
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setSpeedTargets_MT()

    isMT = true;
    cfg = getMockConfig(isMT);

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(cfg.design.nbRepetitions * 2, cfg.design.nbEventsPerBlock) * 28);

    % try when the target are just for the fixation cross
    cfg.target.type = {'fixation_cross'};

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(cfg.design.nbRepetitions * 2, cfg.design.nbEventsPerBlock) * 28);

end

function test_setSpeedTargets_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(cfg.design.nbRepetitions ...
                             * length(cfg.design.names) ...
                             * length(cfg.design.fixationPosition), ...
                             cfg.design.nbEventsPerBlock) * 28);

    % try when the target are just for the fixation cross
    cfg.target.type = {'fixation_cross'};

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(cfg.design.nbRepetitions ...
                             * length(cfg.design.names) ...
                             * length(cfg.design.fixationPosition), ...
                             cfg.design.nbEventsPerBlock) * 28);

end
