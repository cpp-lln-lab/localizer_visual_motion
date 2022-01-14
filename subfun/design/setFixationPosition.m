function blockFixationPosition = setFixationPosition(cfg)
    %
    % blockFixationPosition = setFixationPosition(cfg)
    %
    % Compute the fixation position (center of the stimulation) for the MT/MST localizer
    % in a matrix of size ``nbBlocks`` by ``nbEventsPerBlock``
    %
    %
    % (C) Copyright 2022 CPP visual motion localizer developpers

    % Get the parameter to compute the design with
    [nbRepetitions, nbEventsPerBlock, ~, nbBlocks] = getDesignInput(cfg);

    % Output an "empty" matrix in case of no MT/MST localizer
    if ~strcmp(cfg.design.localizer, 'MT_MST')

        blockFixationPosition = zeros(nbBlocks, nbEventsPerBlock);

    else % Compute the matrix with the fixation position if requested

        % here we double the repetions if 2 hemifields
        nbRepetitions = nbRepetitions * length(cfg.design.fixationPosition);

        if length(cfg.design.names) == 1

            nbBlocksPerHemifield = nbRepetitions;

        elseif length(cfg.design.names) == 2

            nbBlocksPerHemifield = nbRepetitions * length(cfg.design.names);

        end

        blockFixationPosition = repmat(cfg.design.fixationPosition(1), ...
                                       nbBlocksPerHemifield, ...
                                       1);

        if length(cfg.design.fixationPosition) == 2

            blockFixationPosition = [blockFixationPosition; ...
                                     repmat(cfg.design.fixationPosition(2), ...
                                            nbBlocksPerHemifield, ...
                                            1)];

        end

    end

end
