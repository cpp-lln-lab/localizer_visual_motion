% (C) Copyright 2021 CPP visual motion localizer developpers

function speeds = setSpeedTargets(cfg)

    [~, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);

    speeds = ones(nbBlocks, nbEventsPerBlock) * cfg.dot.speedPixPerFrame;

end
