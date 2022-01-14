function test_suite = test_setBlocksConditions %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getDirectionBaseVectors_MT()

    isMT = true;
    cfg = getMockConfig(isMT);

    [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    assertEqual(conditionNamesVector, repmat({'static'; 'motion'}, 12, 1));
    assertEqual(idxCondition1, [1:2:23]');
    assertEqual(idxCondition2, [2:2:24]');

end

function test_getDirectionBaseVectors_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    assertEqual(conditionNamesVector, repmat({'static'; 'motion'}, 24, 1));
    assertEqual(idxCondition1, [1:2:47]');
    assertEqual(idxCondition2, [2:2:48]');

end
