function test_suite = test_setDirections %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setDirectionsMT()

    run ../initEnv();

    isMT = true;
    cfg = getMockConfig(isMT);

    directions = setDirections(cfg);

    assertEqual(size(directions), [24, 12]);

    % only left right and static
    assertEqual(unique(directions), [-1; 0; 180]);

    % static every second block
    assertEqual(directions(1:2:end, :), ones(12, 12) * -1);

end

function test_setDirectionsMST()

    run ../initEnv();

    isMT = false;
    cfg = getMockConfig(isMT);

    directions = setDirections(cfg);

    assertEqual(size(directions), [48, 24]);

    % only left right and static
    assertEqual(unique(directions), [-666; -1; 666]);

end
