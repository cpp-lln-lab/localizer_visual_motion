% (C) Copyright 2020 CPP visual motion localizer developpers

function [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg)
    nbRepetitions = cfg.design.nbRepetitions;
    nbEventsPerBlock = cfg.design.nbEventsPerBlock;
    maxNbPerBlock = cfg.target.maxNbPerBlock;
    nbBlocks = length(cfg.design.names) * nbRepetitions;
end
