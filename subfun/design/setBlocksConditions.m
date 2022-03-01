function [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg)
    %
    % [conditionNamesVector, idxCondition1, idxCondition2] = setBlocksConditions(cfg)
    %
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    nbRepetitions = getDesignInput(cfg);

    conditionNamesVector = repmat(cfg.design.names, nbRepetitions, 1);

    % Get the index of each condition
    nameCondition1 = 'static';
    nameCondition2 = 'motion';

    if  strcmp(cfg.design.localizer, 'MT') || ...
            strcmp(cfg.design.localizer, 'MT_MST') && length(cfg.design.names) == 2

        idxCondition1 = find(strcmp(conditionNamesVector, nameCondition1));

    else

        idxCondition1 = [];

    end

    idxCondition2 = find(strcmp(conditionNamesVector, nameCondition2));

end
