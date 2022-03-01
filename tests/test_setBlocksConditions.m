function test_suite = test_setBlocksConditions %#ok<*STOUT>
    % (C) Copyright 2021 CPP visual motion localizer developers
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

    conditions = {'static'; 'motion'};
    nbRepeats = cfg.design.nbRepetitions;

    assertEqual(conditionNamesVector, repmat(conditions, nbRepeats, 1));
    assertEqual(idxCondition1, (1:2:numel(conditions) * nbRepeats)');
    assertEqual(idxCondition2, (2:2:numel(conditions) * nbRepeats)');

end

function test_getDirectionBaseVectors_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg);

    conditions = {'static'; 'motion'};
    nbRepeats = cfg.design.nbRepetitions * length(cfg.design.fixationPosition);

    assertEqual(conditionNamesVector, repmat(conditions, nbRepeats, 1));
    assertEqual(idxCondition1, (1:2:numel(conditions) * nbRepeats)');
    assertEqual(idxCondition2, (2:2:numel(conditions) * nbRepeats)');

end
