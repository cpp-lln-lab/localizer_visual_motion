function test_suite = test_setSpeedTargets %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setSpeedTargetsBasic()

    isMT = true;
    cfg = getMockConfig(isMT);

    speeds = setSpeedTargets(cfg);

    assertEqual(speeds, ones(24, 12) * 28);

    % try when the target are just for the fixation cross
    cfg.target.type = {'fixation_cross'};

    speeds = setSpeedTargets(cfg);

    % not sure why the fixation cross should have a speed ????
    assertEqual(speeds, ones(24, 12));

end
