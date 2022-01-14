function speeds = setSpeedTargets(cfg)
    %
    % USAGE::
    %
    %  speeds = setSpeedTargets(cfg)
    %
    % If selected as task, it computes the matrix with the speeds set in
    % ``cfg.dot.speed`` (computed in pixels per frame) and the target ones (higher = faster,
    % lower = slower).
    %
    % If this task is not requested, the output will be a matrix where the values correspond to the
    % set speed in ``cfg.dot.speed`` (computed in pixels per frame).
    %
    %
    % (C) Copyright 2021 CPP visual motion localizer developpers

    [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);
    speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;

    % TODO: make the output different whether the task is selected or not.
    %     if ismember('speed', cfg.target.type)
    %     else % Outputs an "empty" matrix in case no speed task is required
    %     end

end
