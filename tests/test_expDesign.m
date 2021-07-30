function test_suite = test_expDesign %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_exDesignBasic()

    displayFigs = 1;

    isMT = true;

    run ../initEnv();

    cfg = getTestConfig(isMT);

    [cfg] = expDesign(cfg, displayFigs);

end
