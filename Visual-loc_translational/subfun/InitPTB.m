function [Cfg] = InitPTB(Cfg)

% For octave: to avoid displaying messenging one screen at a time
more off

% check for OpenGL compatibility, abort otherwise:
AssertOpenGL;

% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');

% Hide the mouse cursor:
HideCursor;

% Don't echo keypresses to Matlab window
ListenChar(2);

% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
KbCheck;
WaitSecs(0.1);
GetSecs;

% Open a fullscreen, onscreen window with gray background. Enable 32bpc
% floating point framebuffer via imaging pipeline on it.
PsychImaging('PrepareConfiguration');

% Intialize PsychPortAudio
InitializePsychSound(1);

% init PTB with different options in concordance to the Debug Parameters
if Cfg.debug
    
    % set to one because we don not care about time
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'Verbosity', 0);
    Screen('Preferences', 'SuppressAllWarnings', 2);
    
    if Cfg.testingSmallScreen
        [Cfg.win, Cfg.winRect] = PsychImaging('OpenWindow', Cfg.screen, Cfg.backgroundColor,  [0,0, 480, 270]);
    else
        if Cfg.testingTranspScreen
        PsychDebugWindowConfiguration
        end
        [Cfg.win, Cfg.winRect] = PsychImaging('OpenWindow', Cfg.screen, Cfg.backgroundColor);
    end
    
else
    Screen('Preference','SkipSyncTests', 0);
    [Cfg.win, Cfg.winRect] = PsychImaging('OpenWindow', Cfg.screen, Cfg.backgroundColor);
    
end

% Retrieve window size info
[Cfg.winWidth, Cfg.winHeight] = WindowSize(Cfg.win);

% Set priority for script execution to realtime priority:
Priority(MaxPriority(Cfg.win));

if strcmp(Cfg.stimPosition,'Scanner')
    Cfg.winRect(1,4) = Cfg.winRect(1,4)*2/3;
end

% Computes the number of pixels per degree given the distance to screen and
% monitor width
V = 2*(180*(atan(Cfg.monitorWidth/(2*Cfg.screenDistance))/pi));
Cfg.ppd = Cfg.winRect(3)/V;
% Select specific text font, style and size:
Screen('TextFont',Cfg.win, Cfg.textFont );
Screen('TextSize',Cfg.win, Cfg.textSize);
Screen('TextStyle', Cfg.win, Cfg.textStyle);

% Get the Center of the Screen
Cfg.center = [Cfg.winRect(3), Cfg.winRect(4)]/2;

% Query frame duration
Cfg.ifi = Screen('GetFlipInterval', Cfg.win);
Cfg.monRefresh = 1/Cfg.ifi;

% Enable alpha-blending, set it to a blend equation useable for linear
% superposition with alpha-weighted source.
Screen('BlendFunction', Cfg.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initially sync us to VBL at start of animation loop.
Cfg.vbl = Screen('Flip', Cfg.win);

end
