% (C) Copyright 2021 CPP visual motion localizer developpers

% [ W I P ] 

function speeds = setSpeedTargets(cfg)

    % Compute the matrix with the speed targets if requested, otherwise output will be only zeros
    if sum(contains(cfg.target.type, 'speed')) ~= 0

        [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);

        speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;
    
    else

        % Outpu an "empty" matrix in case no speed task is required
        [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);

        speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;
        
    end

end
