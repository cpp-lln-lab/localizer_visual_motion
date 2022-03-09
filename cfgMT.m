function cfg = cfgMT()
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT';

    cfg.subject.subjectGrp = 'pilot';
    cfg.subject.sessionNb = 1;
    cfg.subject.askGrpSess = [false false];

    cfg.verbose = 1;

    cfg.debug.do = false;
    cfg.debug.transpWin = false;
    cfg.debug.smallWin = false;

    cfg.pacedByTriggers.do = false;

    cfg.eyeTracker.do = false;

    cfg.design.nbRepetitions = 15;

    cfg.timing.eventDuration = 0.43; % second

end
