function cfg = getTestConfig(isMT)
    % fixture
    %
    % (C) Copyright 2020 CPP visual motion localizer developpers

    if nargin < 1
        isMT =  true;
    end

    if isMT
        cfg.design.localizer = 'MT';
        % choices: [ 0 90 180 270 ] right down left up
        cfg.design.motionDirections = [0 180];
        cfg.design.names = {'static'; 'motion'};

    else
        cfg.design.localizer = 'MT_MST';
        % choices [666 -666] outward inward
        cfg.design.motionDirections = [666 -666];
        cfg.design.names = {'motion'};
        cfg.design.fixationPosition = {'fixation_left'; 'fixation_right'};

    end

    cfg.target.type = {'fixation_cross', 'speed'};
    cfg.target.maxNbPerBlock = 2;

    cfg.dot.speedPixPerFrame = 28;

    cfg.design.nbRepetitions = 10;
    cfg.design.nbEventsPerBlock = 12;

end
