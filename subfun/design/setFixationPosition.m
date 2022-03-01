function blockFixationPosition = setFixationPosition(cfg)
    %
    % blockFixationPosition = setFixationPosition(cfg)
    %
    % Compute the fixation position (center of the stimulation) for the MT/MST localizer
    % in a matrix of size ``nbBlocks`` by ``nbEventsPerBlock``
    %
    %
    % (C) Copyright 2022 CPP visual motion localizer developers

    % Get the parameter to compute the design with
    [~, ~, ~, nbBlocks] = getDesignInput(cfg);

    % Output an "empty" matrix in case of no MT/MST localizer
    if ~strcmp(cfg.design.localizer, 'MT_MST')

        blockFixationPosition = zeros(nbBlocks, 1);

    else % Compute the matrix with the fixation position if requested

        nbBlocksPerHemifield = nbBlocks / length(cfg.design.fixationPosition);

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
