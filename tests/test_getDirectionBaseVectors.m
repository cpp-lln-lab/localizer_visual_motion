function test_suite = test_getDirectionBaseVectors %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getDirectionBaseVectors_MT()

    isMT = true;
    cfg = getMockConfig(isMT);

    [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg);

    assertEqual(directionsCondition1, [-1 -1]);
    assertEqual(directionsCondition2, [0 180]);

end

function test_getDirectionBaseVectors_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    [directionsCondition1, directionsCondition2] = getDirectionBaseVectors(cfg);

    assertEqual(directionsCondition1, [-1 -1]);
    assertEqual(directionsCondition2, [666 -666]);

end
