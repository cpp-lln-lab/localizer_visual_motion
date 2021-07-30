function test_suite = test_setBlocksConditions %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getDirectionBaseVectorsBasic()

    run ../initEnv();

    isMT = true;
    cfg = getTestConfig(isMT);

    [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    assertEqual(conditionNamesVector, repmat({'static'; 'motion'}, 10, 1));
    assertEqual(idxCondition1, [1; 3; 5; 7; 9; 11; 13; 15; 17; 19]);
    assertEqual(idxCondition2, [2; 4; 6; 8; 10; 12; 14; 16; 18; 20]);

end
