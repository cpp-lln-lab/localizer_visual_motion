function [ExpParameters, Cfg]  = VisualDegree2Pixels(ExpParameters, Cfg)

% Everything is initially in coordinates of visual degrees, 
% convert to pixels (pix/screen) * (screen/rad) * rad/deg
V = 2*(180*(atan(Cfg.monitor_width/(2*Cfg.screen_distance))/pi));
Cfg.ppd = Cfg.winRect(3)/V;

% Covert the aperture diameter to pixels
Cfg.diameter_aperture_ppd = floor(Cfg.diameter_aperture * Cfg.ppd);

% Covert the dot size to pixels
ExpParameters.dotSize_ppd = floor(Cfg.ppd * ExpParameters.dotSize);

end