function cfg = postInitializationSetup(cfg)
    %
    % cfg = postInitializatinSetup(cfg)
    %
    % generic function to finalize some set up after psychtoolbox has been
    % initialized
    %
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg = postInitDots(cfg);

    % TODO transfer those if blocks into 'degToPix' (and similarly into pixToDeg)
    % TODO this kind of generic post initialization can be done systematically at end of initPTB
    if isfield(cfg.fixation, 'xDisplacement')
        cfg.fixation = degToPix('xDisplacement', cfg.fixation, cfg);
    end
    if isfield(cfg.fixation, 'yDisplacement')
        cfg.fixation = degToPix('yDisplacement', cfg.fixation, cfg);
    end

    if isfield(cfg.design, 'xDisplacementAperture')
        cfg.design = degToPix('xDisplacementAperture', cfg.design, cfg);
    end

end
