% (C) Copyright 2020 CPP visual motion localizer developpers

function varargout = postInitializationSetup(varargin)
    % varargout = postInitializatinSetup(varargin)

    % generic function to finalize some set up after psychtoolbox has been
    % initialized

    cfg = deal(varargin{:});

    cfg.dot.matrixWidth = cfg.screen.winWidth;

    % Convert some values from degrees to pixels
    cfg.dot = degToPix('size', cfg.dot, cfg);
    cfg.dot = degToPix('speed', cfg.dot, cfg);

    % Get dot speeds in pixels per frame
    cfg.dot.speedPixPerFrame = cfg.dot.speedPix / cfg.screen.monitorRefresh;

    cfg.aperture = degToPix('xPos', cfg.aperture, cfg);

    % dots are displayed on a square with a length in visual angle equal to the
    % field of view
    cfg.dot.number = round(cfg.dot.density * ...
                           (cfg.dot.matrixWidth / cfg.screen.ppd)^2);

    varargout = {cfg};

end
