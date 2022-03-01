function test_suite = test_checkParameters %#ok<*STOUT>
    % (C) Copyright 2021 CPP visual motion localizer developers
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_checkParameters_basic()

    cfg = checkParameters();

    %     bids.util.jsonencode(fullfile(pwd, 'config_MT_MST.json'), cfg);
    %     expected = cfg;
    %     save(fullfile(pwd, 'config_MT_MST.mat'), 'expected')

    load(fullfile(pwd, 'config_MT_MST.mat'));
    assertEqual(cfg, expected);

end
