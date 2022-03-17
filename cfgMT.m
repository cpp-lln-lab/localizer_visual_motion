function cfg = cfgMT(cfg)
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT';

    cfg.pacedByTriggers.do = true;

    cfg.timing.triggerIBI = 4;

    cfg.mri.triggerNb = 0;

    cfg.design.nbRepetitions = 15;

    cfg.design.nbEventsPerBlock = 12;

    % in Liege is 0.79 (tsry less)
    % in mcas is 0.43
    cfg.timing.eventDuration = 0.79; % .86 second

end
