function test_suite = test_getDesignInput %#ok<*STOUT>
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

    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    assertEqual(nbRepetitions, 10);
    assertEqual(nbEventsPerBlock, 12);
    assertEqual(maxNbPerBlock, 2);
    assertEqual(nbBlocks, 10);

end