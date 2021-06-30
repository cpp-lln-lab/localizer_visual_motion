% (C) Copyright 2020 CPP visual motion localizer developpers

function [conditionNamesVector, CONDITON1_INDEX, CONDITON2_INDEX] = assignConditions(cfg)

    [~, nbRepet] = getDesignInput(cfg);

    conditionNamesVector = repmat(cfg.design.names, nbRepet, 1);

    % Get the index of each condition
    nameCondition1 = 'static';
    nameCondition2 = 'motion';

    if isfield(cfg.design, 'localizer') && strcmpi(cfg.design.localizer, 'MT_MST')

        nameCondition1 = 'static';
        nameCondition2 = 'motion';

    end

    CONDITON1_INDEX = find(strcmp(conditionNamesVector, nameCondition1));
    CONDITON2_INDEX = find(strcmp(conditionNamesVector, nameCondition2));

end
