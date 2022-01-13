function cfg = getMockConfig(isMT)
    % fixture
    %
    % (C) Copyright 2020 CPP visual motion localizer developpers

    if nargin < 1
        isMT =  true;
    end

    %% Set specific localizer configurations as conditions, directions (MT) and stimulation
    %  position (MT_MST)


    %% Nb blocks and events

    % 2 conditions [`cfg.design.names`] and 10 repetitions [`cfg.design.nbRepetitions`]
    % means 20 blocks
    cfg.design.nbRepetitions = 12;
    cfg.design.nbEventsPerBlock = 12;

    if isMT

        cfg.design.localizer = 'MT';
        % choices: [ 0 90 180 270 ] right down left up
        cfg.design.motionDirections = [0 180];
        cfg.design.names = {'static'; 'motion'};

    else

        cfg.design.localizer = 'MT_MST';
        % choices: [666 -666] outward inward
        cfg.design.motionDirections = [666 -666];
        % choices: {'motion'} ; {'static'; 'motion'}
        cfg.design.names = {'static'; 'motion'};
        % choices: {'fixation_left'; 'fixation_right'} ; or only one of the two
        cfg.design.fixationPosition = {'fixation_left'; 'fixation_right'};

        % To not touch

        % here we double the repetions (2 hemifields)
        cfg.design.nbRepetitions = cfg.design.nbRepetitions * length(cfg.design.fixationPosition);

        % inward and outward are presented as separated event
        cfg.design.nbEventsPerBlock = cfg.design.nbEventsPerBlock * 2;


    end

    %% Task

    % choices: {'fixation_cross'} ; {'speed'} ; {'fixation_cross', 'speed'}
    cfg.target.type = {'fixation_cross', 'speed'};
    cfg.target.maxNbPerBlock = 2;

    %% To not touch

    % This is only for a dummy trial of this function.
    % See in `postInitializationSetUp` how it is calculated during the experiment
    cfg.dot.speedPixPerFrame = 28;

end