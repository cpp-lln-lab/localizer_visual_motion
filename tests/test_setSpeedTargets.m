function test_suite = test_setSpeedTargets %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setSpeedTargetsBasic()

    run ../initEnv();

    isMT = true;
    cfg = getTestConfig(isMT);

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(20, 12) * 28);

    % try when the target are just for the fixation cross
    cfg.target.type = {'fixation_cross'};

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(20, 12));

end
