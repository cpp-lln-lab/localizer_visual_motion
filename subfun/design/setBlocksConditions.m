% (C) Copyright 2020 CPP visual motion localizer developpers

function [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg)

    [nbRepetitions] = getDesignInput(cfg);

    conditionNamesVector = repmat(cfg.design.names, nbRepetitions, 1);

    % Get the index of each condition
    nameCondition1 = 'static';
    nameCondition2 = 'motion';

    idxCondition1 = find(strcmp(conditionNamesVector, nameCondition1));
    idxCondition2 = find(strcmp(conditionNamesVector, nameCondition2));

end
