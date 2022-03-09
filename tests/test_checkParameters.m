function test_suite = test_checkParameters %#ok<*STOUT>
    % (C) Copyright 2021 CPP visual motion localizer developers
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_checkParameters_output_dir()

    % set up
    cfg.design.localizer = 'MT';
    cfg = checkParameters(cfg);

    % test
    if ~bids.internal.is_github_ci
        cfg.dir.output = bids.internal.file_utils(cfg.dir.output, 'cpath');
        assertEqual(cfg.dir.output, ...
                    bids.internal.file_utils(fullfile(fileparts(mfilename('fullpath')), ...
                                                      '..', ...
                                                      'output'), ...
                                             'cpath'));

    end

end

function test_checkParameters_no_debug_fullscreen()

    % set up
    cfg.design.localizer = 'MT';
    cfg.debug.do = false;
    cfg.debug.transpWin = 0;
    cfg.debug.smallWin = 0;

    cfg = checkParameters(cfg);

    % prepare expected results
    cfg = removeDirFieldForGithubAction(cfg);

    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'), 'expected');

    expected.debug.do = false;
    expected.debug.transpWin = 0;
    expected.debug.smallWin = 0;
    expected.skipSyncTests = 0;

    % test
    assertEqual(cfg.debug, expected.debug);
    assertEqual(cfg.skipSyncTests, expected.skipSyncTests);

end

function test_checkParameters_no_debug()

    % set up
    cfg.design.localizer = 'MT';
    cfg.debug.do = false;

    cfg = checkParameters(cfg);

    % prepare expected results
    cfg = removeDirFieldForGithubAction(cfg);

    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'), 'expected');

    expected.debug.do = false;
    expected.debug.transpWin = 1;
    expected.debug.smallWin = 1;
    expected.skipSyncTests = 0;

    % test
    assertEqual(cfg.debug, expected.debug);
    assertEqual(cfg.skipSyncTests, expected.skipSyncTests);

end

function test_checkParameters_debug()

    cfg.design.localizer = 'MT';
    cfg.debug.do = true;

    cfg = checkParameters(cfg);

    % prepare expected results
    cfg = removeDirFieldForGithubAction(cfg);

    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'), 'expected');

    expected.debug.do = true;
    expected.debug.transpWin = 1;
    expected.debug.smallWin = 1;
    expected.skipSyncTests = 1;
    expected.hideCursor = 1;

    % test
    assertEqual(cfg.debug, expected.debug);
    assertEqual(cfg.skipSyncTests, expected.skipSyncTests);

end

function test_checkParameters_MT()

    cfg.design.localizer = 'MT';

    cfg = checkParameters(cfg);

    % prepare expected results
    cfg = removeDirFieldForGithubAction(cfg);

    % uncomment for update default config .mat
    %     expected = cfg;
    %     save(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'), 'expected');
    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'), 'expected');

    % test
    checkAllFields(cfg, expected);
    assertEqual(cfg, expected);

end

function test_checkParameters_MT_MST()

    cfg.design.localizer = 'MT_MST';

    cfg = checkParameters(cfg);

    % prepare expected results
    cfg = removeDirFieldForGithubAction(cfg);

    % uncomment for update default config .mat
    %     expected = cfg;
    %     save(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT_MST.mat'), 'expected');
    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT_MST.mat'), 'expected');

    % test
    checkAllFields(cfg, expected);
    assertEqual(cfg, expected);

end

function checkAllFields(cfg, expected)
    fields = fieldnames(expected);
    for i = 1:numel(fields)
        assertEqual(cfg.(fields{i}), expected.(fields{i}));
    end
end

function cfg = removeDirFieldForGithubAction(cfg)
    cfg = rmfield(cfg, 'dir');
end
