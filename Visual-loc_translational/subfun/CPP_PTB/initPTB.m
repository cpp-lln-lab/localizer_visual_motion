function [Cfg] = initPTB(Cfg)
% This seems a good candidate function to have as a common function across
% experiments
% We might want to add a couple of IF in case the experiment does not use
% audio for example.



% For octave: to avoid displaying messenging one screen at a time
more off

% check for OpenGL compatibility, abort otherwise:
AssertOpenGL;


%% Keyboard
% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');


[Cfg.keyboardNumbers, Cfg.keyboardNames] = GetKeyboardIndices;

Cfg.keyboardNumbers

Cfg.keyboardNames

% Computer keyboard to quit if it is necessary
% Cfg.keyboard
% 
% For key presses for the subject
% Cfg.responseBox


switch Cfg.device
    
    
    % this part might need to be adapted because the "default" device
    % number might be different for different OS or set up
    
    
    case 'PC'
        % Computer keyboard to quit if it is necessary
        Cfg.keyboard = [];
        
        % For key presses for the subject
        Cfg.responseBox = [];
        
        
        
        
        
    case 'scanner'
        
    otherwise
        
        % Cfg.keyboard = max(Cfg.keyboardNumbers);
        % Cfg.responseBox = min(Cfg.keyboardNumbers);
        
        Cfg.keyboard = [];
        
        Cfg.responseBox = [];
        
end


testKeyboards(Cfg)


% Don't echo keypresses to Matlab window
ListenChar(-1);


%% Mouse
% Hide the mouse cursor:
HideCursor;


%% Audio
% Intialize PsychPortAudio
InitializePsychSound(1);


%% Visual
% Open a fullscreen, onscreen window with gray background. Enable 32bpc
% floating point framebuffer via imaging pipeline on it.
PsychImaging('PrepareConfiguration');

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


% window size info
[Cfg.winWidth, Cfg.winHeight] = WindowSize(Cfg.win);






% I don't think we want to hard code the 2/3 here. We might just add it to
% the Cfg structure
if strcmp(Cfg.stimPosition,'Scanner')
    Cfg.winRect(1,4) = Cfg.winRect(1,4)*2/3;
end







% Get the Center of the Screen
Cfg.center = [Cfg.winRect(3), Cfg.winRect(4)]/2;

% Computes the number of pixels per degree given the distance to screen and
% monitor width

% This assumes that the window fills the whole screen
V = 2*(180*(atan(Cfg.monitorWidth/(2*Cfg.screenDistance))/pi));
Cfg.ppd = Cfg.winRect(3)/V;


% Enable alpha-blending, set it to a blend equation useable for linear
% superposition with alpha-weighted source.
Screen('BlendFunction', Cfg.win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%% Text and Font
% Select specific text font, style and size:
Screen('TextFont',Cfg.win, Cfg.textFont );
Screen('TextSize',Cfg.win, Cfg.textSize);
Screen('TextStyle', Cfg.win, Cfg.textStyle);


%% Timing
% Query frame duration
Cfg.ifi = Screen('GetFlipInterval', Cfg.win);
Cfg.monRefresh = 1/Cfg.ifi;

% Set priority for script execution to realtime priority:
Priority(MaxPriority(Cfg.win));


%% Warm up some functions
% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
KbCheck;
WaitSecs(0.1);
GetSecs;


%% Initial flip to get a first time stamp
% Initially sync us to VBL at start of animation loop.
Cfg.vbl = Screen('Flip', Cfg.win);


end
