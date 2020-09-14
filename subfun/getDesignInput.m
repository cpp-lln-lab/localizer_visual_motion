function [nbBlocks, nbRepet, nbEventsBlock, maxTargBlock] = getDesignInput(cfg)
    nbRepet = cfg.design.nbRepetitions;
    nbEventsBlock = cfg.design.nbEventsPerBlock;
    maxTargBlock = cfg.target.maxNbPerBlock;
    nbBlocks = length(cfg.design.names) * nbRepet;
end