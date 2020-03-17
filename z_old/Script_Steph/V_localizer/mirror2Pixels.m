function [mirrorPixelPerDegree] = mirror2Pixels (winRect,v_dist,mirror_width)
%This function calculated the mirror pixels per degree and the speed of the
%dots in pixels.

imageHorizDim_InsideMirror = mirror_width;

% Get the screen resolution on the x-axis
screen_resolution= winRect(3);

mirrorDistance = v_dist; % in cm

% Law to covert radians to degrees
% Degrees = 180 * radians / pi    

% Law to calculate visual angles:  V = 2*atan(S/2D)
%  V = 2* atan(imageHorizDim_InsideMirror/(2*mirrorDistance))

%Calculate the visual angle of the viewed mirror.
%(the part where the monitor is visible))
V = 2* (180 * (atan(imageHorizDim_InsideMirror/(2*mirrorDistance)) / pi));

% Calculate the pixels per degree on the mirror surface.
mirrorPixelPerDegree = screen_resolution / V ;
