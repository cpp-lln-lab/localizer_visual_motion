function test_suite = test_checkParameters %#ok<*STOUT>
    % (C) Copyright 2021 CPP visual motion localizer developers
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_checkParameters_MT()

    cfg.design.localizer = 'MT';
    cfg = checkParameters(cfg);
    expected = cfg;
    save(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'), 'expected');
    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT.mat'));
    fields = fieldnames(expected);
    for i = 1:numel(fields)
        assertEqual(cfg.(fields{i}), expected.(fields{i}));
    end

    unfold(cfg);

end

function test_checkParameters_MT_MST()

    cfg.design.localizer = 'MT_MST';
    cfg = checkParameters(cfg);
    expected = cfg;
    save(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT_MST.mat'), 'expected');
    load(fullfile(fileparts(mfilename('fullpath')), 'data', 'config_MT_MST.mat'));
    fields = fieldnames(expected);
    for i = 1:numel(fields)
        assertEqual(cfg.(fields{i}), expected.(fields{i}));
    end

end
