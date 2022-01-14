function test_suite = test_setDirections %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setDirections_MT()

    isMT = true;
    cfg = getMockConfig(isMT);

    directions = setDirections(cfg);

    assertEqual(size(directions), [cfg.design.nbRepetitions * 2, cfg.design.nbEventsPerBlock]);

    % only left right and static
    assertEqual(unique(directions), [-1; 0; 180]);

    % static every second block
    assertEqual(directions(1:2:end, :), ones(cfg.design.nbRepetitions, ...
      cfg.design.nbEventsPerBlock) * -1);

end

function test_setDirections_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    directions = setDirections(cfg);

    assertEqual(size(directions), [cfg.design.nbRepetitions * 2, cfg.design.nbEventsPerBlock]);

    % only left right and static
    assertEqual(unique(directions), [-666; -1; 666]);

end
