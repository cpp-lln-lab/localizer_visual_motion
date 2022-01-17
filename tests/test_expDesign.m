function test_suite = test_expDesign %#ok<*STOUT>
    % (C) Copyright 2021 CPP visual motion localizer developpers
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_expDesign_MT()

    isMT = true;

    cfg = getMockConfig(isMT);

    [cfg] = expDesign(cfg);

end

function test_expDesign_MST()

    isMT = false;

    cfg = getMockConfig(isMT);

    [cfg] = expDesign(cfg);

end
