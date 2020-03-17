function [ExpParameters, Cfg]  = VisualDegree2Pixels(ExpParameters, Cfg)

% Everything is initially in coordinates of visual degrees, 
% convert to pixels (pix/screen) * (screen/rad) * rad/deg
V = 2*(180*(atan(Cfg.monitorWidth/(2*Cfg.screenDistance))/pi));
Cfg.ppd = Cfg.winRect(3)/V;

% Covert the aperture diameter to pixels
Cfg.diameterAperturePpd = floor(Cfg.diameterAperture * Cfg.ppd);

% Covert the dot size to pixels
ExpParameters.dotSizePpd = floor(Cfg.ppd * ExpParameters.dotSize);

end