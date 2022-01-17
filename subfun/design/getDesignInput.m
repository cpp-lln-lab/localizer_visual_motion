function [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg)
    %
    % [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg)
    %
    %
    % (C) Copyright 2020 CPP visual motion localizer developpers

    nbRepetitions = cfg.design.nbRepetitions;
    
    if strcmpi(cfg.design.localizer, 'MT_MST')
    
        % here we double the nb of repetitions (2 hemifields) if needed
        nbRepetitions = nbRepetitions * length(cfg.design.fixationPosition);

    end
    
    nbEventsPerBlock = cfg.design.nbEventsPerBlock;
    maxNbPerBlock = cfg.target.maxNbPerBlock;
    nbBlocks = length(cfg.design.names) * nbRepetitions;
    
end
