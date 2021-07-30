% [ W I P ]

function speeds = setSpeedTargets(cfg)
    % Compute the matrix with the speed targets if requested, otherwise output will be only zeros
    %
    % (C) Copyright 2021 CPP visual motion localizer developpers
    
    if ismember('speed', cfg.target.type)
        [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);
        speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;

    % Outputs an "empty" matrix in case no speed task is required
    else
        [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);
        speeds = zeros(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;

    end

end
