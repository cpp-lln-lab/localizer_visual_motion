function cfg = cfgMT(cfg)
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT';

    cfg.pacedByTriggers.do = true;

    cfg.mri.triggerNb = 0;

    cfg.design.nbRepetitions = 15;

    cfg.timing.eventDuration = 0.43; % .86 second

end
