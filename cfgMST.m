function cfg = cfgMST()
    %
    % (C) Copyright 2020 CPP visual motion localizer developers

    cfg.design.localizer = 'MT_MST';

    cfg.subject.subjectGrp = 'pilot';
    cfg.subject.sessionNb = 1;
    cfg.subject.askGrpSess = [false false];

    cfg.verbose = 1;

    cfg.debug.do = false;
    cfg.debug.transpWin = false;
    cfg.debug.smallWin = false;

    cfg.eyeTracker.do = false;

    cfg.design.nbRepetitions = 10;
    cfg.design.nbEventsPerBlock = 12;

end
