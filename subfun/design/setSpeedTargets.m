function speeds = setSpeedTargets(cfg)
    % If selected as task, it omputes the matrix with the speeds set in
    % ``cfg.dot.speed`` (computed in pixels per frame) and the target ones (higher = faster,
    % lower = slower).
    %
    % If this task is not requeste, the output will be a matrix where the values correspond to the
    % set speed in ``cfg.dot.speed`` (computed in pixels per frame).
    %
    % This function is in * * W I P * *, the output is the same if the task is selected or not.
    %
    % (C) Copyright 2021 CPP visual motion localizer developpers

    if ismember('speed', cfg.target.type)
        [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);
        speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;

        % Outputs an "empty" matrix in case no speed task is required
    else
        [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);
        speeds = ones(nbBlocks, nbEventsPerBlock);

    end

end
