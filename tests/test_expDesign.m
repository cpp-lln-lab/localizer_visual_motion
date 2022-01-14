function test_suite = test_expDesign %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_expDesignBasic()

    isMT = true;

    run ../initEnv();

    cfg = getMockConfig(isMT);

    [cfg] = expDesign(cfg);

end
