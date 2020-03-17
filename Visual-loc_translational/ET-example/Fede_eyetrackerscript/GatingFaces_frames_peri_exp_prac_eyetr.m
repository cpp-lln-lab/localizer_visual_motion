%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Script: Emotional faces - gating                      %%%
%%%  copy to call: GatingFaces_frames_peri_exp_prac_eyetr  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dependent variables: accuracy in emotion discrimination; reaction times
% independent variables: length of the segments (10 levels); emotion (4 or 5 levels) %
% programmer: Federica Falagiarda 17/06/2016 - adapted visual only version 16/11/2016 - adapted with video rendering thru sequence of images 25/01/2019 %

% Gives an output file with: block (can be always 1)
% trial number (200 in total)
% actor number (I have 4 different actors)
% modality (always 1 in this case - auditory and bimodal trials have been removed) %
% segment length (1 is shortes gate 100ms; 10 is longest 400ms; gate size 33ms) %
% emotion of the stim
% reported emotion
% a variable called "i" which is 1 if a correct response is reported, otherwise 0 %
% RTs
% the duration of the stimulus on the screen (needs to be checked for every collected participant - a few stimuli will have odd timings and need to be discarded prior to analyses) %


%% RunEyelinkCode used to  run the Eyelink
% eye tracking
%clc;
%clear all;

% Normally there is a variable called "dummymode" to do the same thing, but
% it causes problem on my mac, so I use this "RunEyelinkCode" variable and
% use an if statement when I want to use it.
RunEyelinkCode = 0;     % Set to 1 when you are testing; 0 when you are running on the computer

SkipSyncTest = 1 ; % 1 will skip screen sync tests for mac issues
% but should be set to 0 during testing (if using a windows/linux)
% EYELINK CODE
if RunEyelinkCode
    dummymode = 0;          %% DUMMY MODE SHOULD BE ZERO WHEN TESTING
    prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
    dlg_title = 'Create EDF file';
    num_lines= 1;
    def     = {'DEMO'};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    %edfFile= 'DEMO.EDF'
    edfFile = answer{1};
    fprintf('EDFFile: %s\n', edfFile );
end

%%% let's define some useful variables/parameters %%%

expName = 'GatingFaces';

% background color (black) and fixation color (white)
white = 255;
black = 0;
bgColor = black;
fixColor = white;
textColor = white;

% other useful variables
stimArray = 1:200;
nBlocks = 2; % can be increased - 1 block has 1 full repetition of trials
%nTrials = 160; % 4 emotions
nTrials = 480; % 4 emotions * 3 locations
%nTrials=5;
% nTrials = 200; % 5 emotions
stimPractice = 1:15;
nPracTrials = 15;
nFrames = 12; % total num of frames in a whole video
stimXsize = 720;
stimYsize = 480;


%% DIALOG BOX %%

prompt = {'Subject Number','Age','Room'};
defaults = {'AAA','99','Behavioral room'};

% show dialog
dialogBox = inputdlg(prompt, 'Setup Information', 1, defaults);

% if return, it goes out of the loop and the current function (I think)
% so it returns if no input is put in the dialog box
if isempty(dialogBox)
    return
end

% save the input of the dialogue box
[subject, age, room] = deal(dialogBox{:});

subjectNum = subject;
subjectAge = str2double(age);
testRoom = room;

%% SET UP OUTPUT FILE %%

dataFileName = [subject expName '.txt'];

% format for the output od the data %
formatString = '%d, %d, %d, %d, %d, %d, %d, %d, %1.3f, %1.3f \n';

% open a file for reading AND writing
% permission 'a' appends data without deleting potential existing content

if exist(dataFileName, 'file') == 0
    dataFile = fopen(dataFileName, 'a');
    
    % header
    fprintf(dataFile, ['Experiment:\t' expName '\n']);
    fprintf(dataFile, ['date:\t' datestr(now) '\n']);
    fprintf(dataFile, ['Subject:\t' subjectNum '\n']);
    fprintf(dataFile, ['Age:\t' num2str(subjectAge) '\n']);
    fprintf(dataFile, ['Room:\t' num2str(testRoom) '\n']);
    
    %data
    fprintf(dataFile, '%s \n', 'block, trial, actor, segment length, emotion, position, response, i, RT, stimlus duration');
    fclose(dataFile);
    
end


%% defining answering keys %%

KbName('UnifyKeyNames');
%answerKeys = [KbName('c'), KbName('v'), KbName('b'), KbName('n'), KbName('m')];
answerKeys = [KbName('c'), KbName('v'), KbName('b'), KbName('n')];


%% INITIALIZE SCREEN AND RUN EXPERIMENT %%

% basic setup checking
AssertOpenGL;

% This sets a PTB preference to possibly skip some timing tests: a value
% of 0 runs these tests, and a value of 1 inhibits them. This
% should always be set to 0 for actual experiments
Screen('Preference', 'SkipSyncTests', 0);
%Screen('Preference', 'SkipSyncTests', 1);
%Screen('Preference', 'SkipSyncTests', 2);

Screen('Preference', 'ConserveVRAM', 4096);

% define default font size for all text uses (i.e. DrawFormattedText fuction)
Screen('Preference', 'DefaultFontSize', 28);

screenVector = Screen('Screens');
screenid = max(screenVector);
% OpenWindow
%[mainWindow, screenRect] = Screen('OpenWindow', max(screenVector), bgColor, [0 0 1000 700], 32, 2);
[mainWindow, screenRect] = Screen('OpenWindow', 0, bgColor, [], 32, 2);
%sc0 0 1000 1200
%[mainWindow, screenRect] = Screen('OpenWindow', 0, bgColor);

% estimate the monitor flip interval for the onscreen window
interFrameInterval = Screen('GetFlipInterval', mainWindow); % in seconds
msInterFrameInterval = interFrameInterval*1000; %in ms

% timings in my trial sequence
ITI = 1 - interFrameInterval/7;
fixationDur = 0.5 - interFrameInterval/7;
responseDur = 4 - interFrameInterval/7;
practiceResponseDur = 5 - interFrameInterval/7;
videoFrameRate = 29.97;
frameDuration = 1/videoFrameRate - interFrameInterval/7;
jitter = [-0.25, 0, 0.25];

% get width and height of the screen
[widthWin, heightWin] = Screen('WindowSize', mainWindow);
widthDis = Screen('DisplaySize', max(screenVector));
Priority(MaxPriority(mainWindow));

% to overcome the well-known randomisation problem
RandStream.setGlobalStream (RandStream('mt19937ar','seed',sum(100*clock)));

% hide mouse cursor
HideCursor(mainWindow);
% Listening enabled and any output of keypresses to Matlabs windows is
% suppressed (see ref. page for ListenChar)
ListenChar(2);

% question mark to be displayed while waiting for the response
questionMark = '?';

% estimate the distance between subject and monitor, in cm
testDistance = 70; % to be changed with real value

%calcualte degree to pixels conversion coefficient
deg2pixCoeff = 1/(atan(widthDis/(widthWin*(testDistance*10)))*180/pi);

% FIXATION CROSS JAZZ %
% define the dimension of the fixation cross in degrees and convert it to
% pixels using the deg2pix coefficient
fixationSizeDeg = 0.3;
fixationSizePix = round(fixationSizeDeg * deg2pixCoeff);

% define the dimension of the line for your fixation cross and convert it
% to pixels
lineSize = 0.05;
lineSizePix = round(lineSize *deg2pixCoeff);

% find the center of the screen and transpose to column
centros = (screenRect(3:4)/2)';
% fixation cross coordinates
fixationXY = repmat(centros, 1, 4) + [0, 0, fixationSizePix, -fixationSizePix; fixationSizePix, -fixationSizePix, 0, 0];

% define distance of stimulus from center of the screen and convert it to pixels %
stimDegDistance = 6;
stimPixDistance = round(stimDegDistance * deg2pixCoeff);
% find stimuli positions
maskingCorrectionLower = -38;
maskingCorrectionUpper = 19;
lowerLocation = [centros(1)-(stimXsize/2),centros(1)+(stimXsize/2);centros(2)+stimPixDistance+ maskingCorrectionLower,centros(2)+stimPixDistance+(stimYsize)+ maskingCorrectionLower];
upperLocation = [centros(1)-(stimXsize/2),centros(1)+(stimXsize/2);centros(2)-stimPixDistance-(stimYsize)+maskingCorrectionUpper,centros(2)-stimPixDistance+maskingCorrectionUpper];


%% Instructions text %%


generalInstructions1 = ['Bienvenue !'...
    '\n \n \n'...
    'Dans cette expérience,'...
    '\n \n'...
    'vous allez devoir faire attention à des visages.'...
    '\n \n \n'...
    'Chaque visage sera associé à une émotion.'...
    '\n \n'...
    'Vous allez devoir identifier la bonne émotion.'...
    '\n \n \n'...
    'Appuyez sur la touche espace pour continuer.'];

generalInstructions2 = ['Les quatre émotions exprimées sur les visages sont:'...
    '\n \n'...
    'La peur'...
    '\n \n'...
    'La colère'...
    '\n \n'...
    'Le dégout'...
    '\n \n'...
    'La joie'...
    '\n \n \n'...
    'Appuyez sur la touche espace pour continuer.'];


generalInstructions3 = ['Les visages pourront apparaitre : '...
    '\n \n'...
    'Soit au centre de l écran'...
    '\n \n'...
    'Soit en haut de l écran'...
    '\n \n'...
    'Soit en bas de l écran'...
    '\n \n \n'...
    'Il est essentiel que vous fixiez toujours la croix de fixation.'...
    '\n \n'...
    'Ne la quittez pas des yeux lorsqu elle est à l écran.'...
    '\n \n \n'...
    'Appuyez sur la touche espace pour continuer.'];


generalInstructions4 = ['Après chaque stimulus,'...
    '\n \n'...
    'un point d interrogation apparaitra sur l écran.'...
    '\n \n'...
    'Vous donnerez votre réponse à ce moment-là.'...
    '\n \n'...
    'Appuyez:'...
    '\n \n'...
    'Le "', KbName(answerKeys(1)),'" touche pour la "peur"'...
    '\n \n'...
    'Le "', KbName(answerKeys(2)),'" touche pour la "colère"'...
    '\n \n'...
    'Le "', KbName(answerKeys(3)),'" la touche pour le "dégout"'...
    '\n \n'...
    'Le "', KbName(answerKeys(4)),'" la touche pour la "joie"'...
    '\n \n \n'...
    'Appuyez sur la touche espace pour continuer.'];

generalInstructions5 = ['Parfois, il est possible'...
    '\n \n'...
    'que vous ne connaissiez pas la réponse'...
    '\n \n'...
    'parce que le stimulus était trop court.'...
    '\n \n'...
    'Cependant, il est important que'...
    '\n \n'...
    'vous essayez toujours de donner une réponse.'...
    '\n \n \n'...
    'Notez que vous allez avoir un temps limité pour répondre:'...
    '\n \n'...
    'Essayez d etre le plus correct possible'...
    '\n \n'...
    'dans votre réponse durant ce laps de temps.'...
    '\n \n \n'...
    'Appuyez sur la touche espace pour continuer.'];

generalInstructions6 = ['Nous vous proposons désormais un entrainement'...
    '\n \n'...
    'pour vous familiariser à la tache.'...
    '\n \n \n'...
    'Appuyez sur la touche espace pour commencer à vous entrainer.'];

endOfPractice = ['L entrainement est terminé'...
    '\n\n\n'...
    'Appuyez sur la touche espace pour commencer'];


breakInstructions = ['Pause !'...
    '\n \n'...
    'Appuyez sur la touche espace quand vous etes prets à continuer la tache.'];


goodbyeMessage = ['L expérience est terminée!'...
    '\n \n'...
    'Merci pour votre temps! :)'];


%% creating my stimuli

An25 = {'25an_1', '25an_2', '25an_3', '25an_4', '25an_5', '25an_6', '25an_7', '25an_8', '25an_9', '25an_10', '25an_11', '25an_12'};
Di25 = {'25di_1', '25di_2', '25di_3', '25di_4', '25di_5', '25di_6', '25di_7', '25di_8', '25di_9', '25di_10', '25di_11', '25di_12'};
Fe25 = {'25fe_1', '25fe_2', '25fe_3', '25fe_4', '25fe_5', '25fe_6', '25fe_7', '25fe_8', '25fe_9', '25fe_10', '25fe_11', '25fe_12'};
Ha25 = {'25ha_1', '25ha_2', '25ha_3', '25ha_4', '25ha_5', '25ha_6', '25ha_7', '25ha_8', '25ha_9', '25ha_10', '25ha_11', '25ha_12'};
An26 = {'26an_1', '26an_2', '26an_3', '26an_4', '26an_5', '26an_6', '26an_7', '26an_8', '26an_9', '26an_10', '26an_11', '26an_12'};
Di26 = {'26di_1', '26di_2', '26di_3', '26di_4', '26di_5', '26di_6', '26di_7', '26di_8', '26di_9', '26di_10', '26di_11', '26di_12'};
Fe26 = {'26fe_1', '26fe_2', '26fe_3', '26fe_4', '26fe_5', '26fe_6', '26fe_7', '26fe_8', '26fe_9', '26fe_10', '26fe_11', '26fe_12'};
Ha26 = {'26ha_1', '26ha_2', '26ha_3', '26ha_4', '26ha_5', '26ha_6', '26ha_7', '26ha_8', '26ha_9', '26ha_10', '26ha_11', '26ha_12'};
An32 = {'32an_1', '32an_2', '32an_3', '32an_4', '32an_5', '32an_6', '32an_7', '32an_8', '32an_9', '32an_10', '32an_11', '32an_12'};
Di32 = {'32di_1', '32di_2', '32di_3', '32di_4', '32di_5', '32di_6', '32di_7', '32di_8', '32di_9', '32di_10', '32di_11', '32di_12'};
Fe32 = {'32fe_1', '32fe_2', '32fe_3', '32fe_4', '32fe_5', '32fe_6', '32fe_7', '32fe_8', '32fe_9', '32fe_10', '32fe_11', '32fe_12'};
Ha32 = {'32ha_1', '32ha_2', '32ha_3', '32ha_4', '32ha_5', '32ha_6', '32ha_7', '32ha_8', '32ha_9', '32ha_10', '32ha_11', '32ha_12'};
An33 = {'33an_1', '33an_2', '33an_3', '33an_4', '33an_5', '33an_6', '33an_7', '33an_8', '33an_9', '33an_10', '33an_11', '33an_12'};
Di33 = {'33di_1', '33di_2', '33di_3', '33di_4', '33di_5', '33di_6', '33di_7', '33di_8', '33di_9', '33di_10', '33di_11', '33di_12'};
Fe33 = {'33fe_1', '33fe_2', '33fe_3', '33fe_4', '33fe_5', '33fe_6', '33fe_7', '33fe_8', '33fe_9', '33fe_10', '33fe_11', '33fe_12'};
Ha33 = {'33ha_1', '33ha_2', '33ha_3', '33ha_4', '33ha_5', '33ha_6', '33ha_7', '33ha_8', '33ha_9', '33ha_10', '33ha_11', '33ha_12'};

% one structure per "video"
An25Struct = struct;
for i=1:nFrames
    An25Struct(i).stimNames = An25{i};
    An25Struct(i).stimImage = imread([cd '/V' An25{i} '.png']);
    An25Struct(i).duration = frameDuration;
    An25Struct(i).imageTexture = Screen('MakeTexture', mainWindow, An25Struct(i).stimImage);
end
Di25Struct = struct;
for i=1:nFrames
    Di25Struct(i).stimNames = Di25{i};
    Di25Struct(i).stimImage = imread([cd '/V' Di25{i} '.png']);
    Di25Struct(i).duration = frameDuration;
    Di25Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Di25Struct(i).stimImage);
end
Fe25Struct = struct;
for i=1:nFrames
    Fe25Struct(i).stimNames = Fe25{i};
    Fe25Struct(i).stimImage = imread([cd '/V' Fe25{i} '.png']);
    Fe25Struct(i).duration = frameDuration;
    Fe25Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Fe25Struct(i).stimImage);
end
Ha25Struct = struct;
for i=1:nFrames
    Ha25Struct(i).stimNames = Ha25{i};
    Ha25Struct(i).stimImage = imread([cd '/V' Ha25{i} '.png']);
    Ha25Struct(i).duration = frameDuration;
    Ha25Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Ha25Struct(i).stimImage);
end
An26Struct = struct;
for i=1:nFrames
    An26Struct(i).stimNames = An26{i};
    An26Struct(i).stimImage = imread([cd '/V' An26{i} '.png']);
    An26Struct(i).duration = frameDuration;
    An26Struct(i).imageTexture = Screen('MakeTexture', mainWindow, An26Struct(i).stimImage);
end
Di26Struct = struct;
for i=1:nFrames
    Di26Struct(i).stimNames = Di26{i};
    Di26Struct(i).stimImage = imread([cd '/V' Di26{i} '.png']);
    Di26Struct(i).duration = frameDuration;
    Di26Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Di26Struct(i).stimImage);
end
Fe26Struct = struct;
for i=1:nFrames
    Fe26Struct(i).stimNames = Fe26{i};
    Fe26Struct(i).stimImage = imread([cd '/V' Fe26{i} '.png']);
    Fe26Struct(i).duration = frameDuration;
    Fe26Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Fe26Struct(i).stimImage);
end
Ha26Struct = struct;
for i=1:nFrames
    Ha26Struct(i).stimNames = Ha26{i};
    Ha26Struct(i).stimImage = imread([cd '/V' Ha26{i} '.png']);
    Ha26Struct(i).duration = frameDuration;
    Ha26Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Ha26Struct(i).stimImage);
end
An32Struct = struct;
for i=1:nFrames
    An32Struct(i).stimNames = An32{i};
    An32Struct(i).stimImage = imread([cd '/V' An32{i} '.png']);
    An32Struct(i).duration = frameDuration;
    An32Struct(i).imageTexture = Screen('MakeTexture', mainWindow, An32Struct(i).stimImage);
end
Di32Struct = struct;
for i=1:nFrames
    Di32Struct(i).stimNames = Di32{i};
    Di32Struct(i).stimImage = imread([cd '/V' Di32{i} '.png']);
    Di32Struct(i).duration = frameDuration;
    Di32Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Di32Struct(i).stimImage);
end
Fe32Struct = struct;
for i=1:nFrames
    Fe32Struct(i).stimNames = Fe32{i};
    Fe32Struct(i).stimImage = imread([cd '/V' Fe32{i} '.png']);
    Fe32Struct(i).duration = frameDuration;
    Fe32Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Fe32Struct(i).stimImage);
end
Ha32Struct = struct;
for i=1:nFrames
    Ha32Struct(i).stimNames = Ha32{i};
    Ha32Struct(i).stimImage = imread([cd '/V' Ha32{i} '.png']);
    Ha32Struct(i).duration = frameDuration;
    Ha32Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Ha32Struct(i).stimImage);
end
An33Struct = struct;
for i=1:nFrames
    An33Struct(i).stimNames = An33{i};
    An33Struct(i).stimImage = imread([cd '/V' An33{i} '.png']);
    An33Struct(i).duration = frameDuration;
    An33Struct(i).imageTexture = Screen('MakeTexture', mainWindow, An33Struct(i).stimImage);
end
Di33Struct = struct;
for i=1:nFrames
    Di33Struct(i).stimNames = Di33{i};
    Di33Struct(i).stimImage = imread([cd '/V' Di33{i} '.png']);
    Di33Struct(i).duration = frameDuration;
    Di33Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Di33Struct(i).stimImage);
end
Fe33Struct = struct;
for i=1:nFrames
    Fe33Struct(i).stimNames = Fe33{i};
    Fe33Struct(i).stimImage = imread([cd '/V' Fe33{i} '.png']);
    Fe33Struct(i).duration = frameDuration;
    Fe33Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Fe33Struct(i).stimImage);
end
Ha33Struct = struct;
for i=1:nFrames
    Ha33Struct(i).stimNames = Ha33{i};
    Ha33Struct(i).stimImage = imread([cd '/V' Ha33{i} '.png']);
    Ha33Struct(i).duration = frameDuration;
    Ha33Struct(i).imageTexture = Screen('MakeTexture', mainWindow, Ha33Struct(i).stimImage);
end


%% Build structure containing all the stimuli structures and the trials information

% three locations
myStimuliStructuresArray = {An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct;...
    Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct;...
    Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct;...
    Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct;...
    An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct;...
    Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct;...
    Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct;...
    Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct;...
    An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct;...
    Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct;...
    Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct;...
    Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct;...
    An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct;...
    Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct;...
    Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct;...
    Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct;...
    An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct;...
    Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct;...
    Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct;...
    Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct;...
    An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct;...
    Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct;...
    Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct;...
    Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct;...
    An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct;...
    Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct;...
    Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct;...
    Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct;...
    An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct;...
    Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct;...
    Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct;...
    Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct;...
    An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct; An25Struct;...
    Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct; Di25Struct;...
    Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct; Fe25Struct;...
    Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct; Ha25Struct;...
    An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct; An26Struct;...
    Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct; Di26Struct;...
    Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct; Fe26Struct;...
    Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct; Ha26Struct;...
    An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct; An32Struct;...
    Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct; Di32Struct;...
    Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct; Fe32Struct;...
    Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct; Ha32Struct;...
    An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct; An33Struct;...
    Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct; Di33Struct;...
    Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct; Fe33Struct;...
    Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct; Ha33Struct};

% % without sadness
% % WRONG
% myEmotions = repmat([repmat(1,1,30),repmat(2,1,30),repmat(3,1,30),repmat(4,1,30)],1,4); %,repmat(5,1,10)],1,4);
% myActor = [repmat(1,1,120),repmat(2,1,120),repmat(3,1,120),repmat(4,1,120)];
% mySegmLength = repmat(1:10,1,48);
% mySegmLength = mySegmLength+2; % because the stimuli have 10 different durations but between 3 and 12 frames

% without sadness
myEmotions = repmat([repmat(1,1,10),repmat(2,1,10),repmat(3,1,10),repmat(4,1,10)],1,12); %,repmat(5,1,10)],1,4);
myActor = repmat([repmat(1,1,40),repmat(2,1,40),repmat(3,1,40),repmat(4,1,40)],1,1,3);
mySegmLength = repmat(1:10,1,48);
mySegmLength = mySegmLength+2; % because the stimuli have 10 different durations but between 3 and 12 frames


% TRIPLE THE NUMBER OF TRIALS (POSITION COLUMN HAS BEEN ADDED)

myExpTrials = struct;
% for the experiment
for t = 1:nTrials
    myExpTrials(t).stimuli = myStimuliStructuresArray{t};
    myExpTrials(t).emotion = myEmotions(t);
    myExpTrials(t).actor = myActor(t);
    myExpTrials(t).gate = mySegmLength(t);
    myExpTrials(t).position = []; % SHOULD CORRESPOND TO CENTER
    myExpTrials(t).location = 2;
end

% CHANGE POSITION IN 2 THIRDS OF THE TRIALS

for locone = 1:nTrials/3
    myExpTrials(locone).position = upperLocation;
    myExpTrials(locone).location = 1;
end

for loctwo = 1+nTrials/3:2*(nTrials/3)
    myExpTrials(loctwo).position = lowerLocation;
    myExpTrials(loctwo).location = 3;
end
% shuffle everything
myExpTrials = Shuffle(myExpTrials);


%% GENERAL INSTRUCTIONS
% display initial instructions
DrawFormattedText(mainWindow, generalInstructions1, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');

DrawFormattedText(mainWindow, generalInstructions2, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');

DrawFormattedText(mainWindow, generalInstructions3, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');

DrawFormattedText(mainWindow, generalInstructions4, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');

DrawFormattedText(mainWindow, generalInstructions5, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');

DrawFormattedText(mainWindow, generalInstructions6, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');



%% pre-practice: participants will learn the four response keys
myPrePractice = struct;
feedbackCoordinates = [widthWin/2-30,heightWin/2-30,widthWin/2+30,heightWin/2+30];
nppTrials = 24;
learnedKey = zeros(nppTrials,1);

emotionWords = {'COLÈRE','COLÈRE','COLÈRE','COLÈRE','COLÈRE','COLÈRE',...
    'DÉGOUT','DÉGOUT','DÉGOUT','DÉGOUT','DÉGOUT','DÉGOUT',...
    'PEUR','PEUR','PEUR','PEUR','PEUR','PEUR',...
    'JOIE','JOIE','JOIE','JOIE','JOIE','JOIE'};
emotions = [repmat(1,1,6),repmat(2,1,6),repmat(3,1,6),repmat(4,1,6)];

for pp = 1:nppTrials
    myPrePractice(pp).word = emotionWords{pp};
    myPrePractice(pp).emotion = emotions(pp);
end
myPrePractice = Shuffle(myPrePractice);


% Prepractive loop
for l = 1:nppTrials
    
    
    Screen('FillRect', mainWindow, bgColor);
    Screen('Flip', mainWindow);
    WaitSecs(0.1);
    DrawFormattedText(mainWindow, myPrePractice(l).word, 'center', 'center', textColor);
    [vlb] = Screen('Flip', mainWindow);
    
    
    t1 = 0;
    while t1 < practiceResponseDur
        [keyIsDown, time, key] = KbCheck;
        
        if keyIsDown
            break
        end
        
        t2 = GetSecs;
        t1 = t2 - vlb;
        
    end
    
    % escape loop with Q button
    if strcmp(KbName(find(key)),'q')
        ListenChar;
        sca;
        fclose all;
        ShowCursor;
    else
        % if the pressed key is different from Q
        learnKeyKey = KbName(KbName(find(key)));
    end
    
    
    % if no keypress is reported, assign value 999
    if numel(learnKeyKey) ~= 0
        learnKeyKey = learnKeyKey(1);
    else
        learnKeyKey = 999;
        learnedKey(l) = 999;
    end
    
    prePracticeKey = find(answerKeys == learnKeyKey);
    
    
    % determine what has been pressed
    if prePracticeKey == 1
        learnedKey(l) = 3; % 'C' has been pressed
    elseif prePracticeKey == 2
        learnedKey(l) = 1; % 'V' has been pressed
    elseif prePracticeKey == 3
        learnedKey(l) = 2; % 'B' has been pressed
    elseif prePracticeKey == 4
        learnedKey(l) = 4; % 'N' has been pressed
    end
    
    
    % feedback
    if learnedKey(l) == myPrePractice(l).emotion
        % green feedback
        Screen('FillOval', mainWindow, [0 255 0], feedbackCoordinates);
        Screen('Flip', mainWindow);
        WaitSecs(0.5)
        
    elseif learnedKey(l) == 999 % time was out and no response given
        % time out feedback
        feedbackMessage = 'Time out!';
        DrawFormattedText(mainWindow, feedbackMessage, 'center', 'center', textColor);
        Screen('Flip', mainWindow);
        WaitSecs(0.5);
        
    elseif (learnedKey(l) == 1 || learnedKey(l) == 2 || learnedKey(l) == 3 || learnedKey(l) == 4) && learnedKey(l) ~= myPrePractice(l).emotion
        %red feedback
        Screen('FillOval', mainWindow, [255 0 0], feedbackCoordinates);
        Screen('Flip', mainWindow);
        WaitSecs(0.5)
        
    else
        % wrong key press feedback
        feedbackMessage = 'Invalid key!';
        DrawFormattedText(mainWindow, feedbackMessage, 'center', 'center', textColor);
        Screen('Flip', mainWindow);
        WaitSecs(0.5);
    end
    
    
end

%end of prepractice
DrawFormattedText(mainWindow, 'This is the end of the pre-practice', 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');


%% PRACTICE BLOCK : a few trials to familiarize with the task
% number of trials in the practice
nPracTrials = 16;
nPracBlocks = 2;
pressedkey = zeros(nPracTrials, 1);
myPracTrials = struct;
correctvect = zeros(nPracTrials, 1);

myPracticeStructuresArray = {An25Struct; Di25Struct; Fe25Struct; Ha25Struct;...
    An26Struct; Di26Struct; Fe26Struct; Ha26Struct;...
    An32Struct; Di32Struct; Fe32Struct; Ha32Struct;...
    An33Struct; Di33Struct; Fe33Struct; Ha33Struct};
pracEmotions = repmat([1:4],1,4);

for p=1:nPracTrials
    myPracTrials(p).stimuli = myPracticeStructuresArray{p};
    myPracTrials(p).gate = 12; % always longest stimuli
    myPracTrials(p).position = [];
    myPracTrials(p).emotion = pracEmotions(p);
end

myPracTrials = Shuffle(myPracTrials);

% % to add peripheral location to the practice
%
% for locone = 1:nPracTrials/4
%     myPracTrials(locone).position = upperLocation;
% end
%
% for loctwo = 1+nPracTrials/4:2*(nPracTrials/4)
%     myPracTrials(loctwo).position = lowerLocation;
% end


for pb = 1:nPracBlocks
    
    % shuffle qt the beginning of each block
    myPracTrials = Shuffle(myPracTrials);
    
    for ptrial=1:nPracTrials
        
        % select structure for practice
        currentStimulus = myPracTrials(ptrial).stimuli;
        
        % random jitter
        j = jitter(randperm(3));
        
        % set the screen to background color
        Screen('FillRect', mainWindow, bgColor);
        [~, ~, lastEventTime] = Screen('Flip', mainWindow);
        
        % draw fixation cross
        Screen('DrawLines', mainWindow, fixationXY, lineSizePix, fixColor);
        [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+ITI);
        
        % time stamp for frame presentation
        Screen('FillRect', mainWindow, bgColor);
        [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+fixationDur+j(1));
        
        
        % frames presentation loop
        for g = 1:myPracTrials(ptrial).gate
            Screen('DrawTexture', mainWindow, currentStimulus(g).imageTexture, [], myPracTrials(ptrial).position, 0);
            Screen('DrawLines', mainWindow, fixationXY, lineSizePix, fixColor);
            [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
            
            % time stamp to measure stimulus duration on screen
            if g == 1
                beginStimulus = GetSecs;
            end
            
        end
        
        % draw question mark and flip it to the screen
        DrawFormattedText(mainWindow, questionMark, 'center', 'center', white);
        [vlb, sTime, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
        
        % time stamp for RT and stimulus measurement - start measuring RTs from here
        % it's also the en-of-stimulus time stamp
        tStart = GetSecs;
        
        % while loop waiting for a keypress
        t1 = 0;
        while t1 < responseDur
            [keyIsDown, time, key] = KbCheck;
            
            if keyIsDown
                RT(ptrial) = (GetSecs - tStart)*1000;
                break
            end
            
            t2 = GetSecs;
            t1 = t2 - vlb;
            
        end
        
        
        % escape loop with Q button
        if strcmp(KbName(find(key)),'q')
            ListenChar;
            sca;
            fclose all;
            ShowCursor;
        else
            % if the pressed key is different from Q
            pressedKey = KbName(KbName(find(key)));
        end
        
        
        % if no keypress is reported, assign value 999
        if numel(pressedKey) ~= 0
            pressedKey = pressedKey(1);
        else
            pressedKey = 999;
        end
        
        % find matching between the key pressed by the subject and the
        % response keys defined earlier.
        % If the subject did not press any of the given keys,
        % trialResponseKey will be empty; otherwise it will return a vector
        % with the poition, in answerKeys, of the found correspondece
        trialResponseKey = find(answerKeys == pressedKey);
        
        % careful with mapping keys and emotions here!!
        % (to be changed if a 5th emoyion is added)
        
        if trialResponseKey == 1
            pressedkey(ptrial) = 3; % 'C' has been pressed % 3 = FEAR
        elseif trialResponseKey == 2
            pressedkey(ptrial) = 1; % 'V' has been pressed % 1 = ANGER
        elseif trialResponseKey == 3
            pressedkey(ptrial) = 2; % 'B' has been pressed % 2 = DISGUST
        elseif trialResponseKey == 4
            pressedkey(ptrial) = 4; % 'N' has been pressed % 4 = JOY
        end
        
        % feedback
        if pressedkey(ptrial) == myPracTrials(ptrial).emotion
            % green feedback
            Screen('FillOval', mainWindow, [0 255 0], feedbackCoordinates);
            Screen('Flip', mainWindow);
            WaitSecs(0.5)
            correctvect(ptrial) = 1;
            
        elseif pressedkey(ptrial) == 999 % time was out and no response given
            % time out feedback
            feedbackMessage = 'Time out!';
            DrawFormattedText(mainWindow, feedbackMessage, 'center', 'center', textColor);
            Screen('Flip', mainWindow);
            WaitSecs(0.5);
            
        elseif (pressedkey(ptrial) == 1 || pressedkey(ptrial) == 2 || pressedkey(ptrial) == 3 || pressedkey(ptrial) == 4) && pressedkey(ptrial) ~= myPracTrials(ptrial).emotion
            %red feedback
            Screen('FillOval', mainWindow, [255 0 0], feedbackCoordinates);
            Screen('Flip', mainWindow);
            WaitSecs(0.5)
            
        else
            % wrong key press feedback
            feedbackMessage = 'Invalid key!';
            DrawFormattedText(mainWindow, feedbackMessage, 'center', 'center', textColor);
            Screen('Flip', mainWindow);
            WaitSecs(0.5);
        end
        
        
    end
    
    if sum(correctvect)/nPracTrials < 0.8
        nPracBlocks = 3;
    end
    
    
end

% end of the practice block
DrawFormattedText(mainWindow, endOfPractice, 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');


% START USING THE EYELINK AFTER OPENING A NEW WINDOW/SCREEN USING
% PSYCHTOOLBOX.
% The following prepares the initial setup, and calibration
%% EYELINK
if RunEyelinkCode
    
    el=EyelinkInitDefaults(mainWindow);
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    % the following code is used to check the version of the eye tracker
    % and version of the host software
    sw_version = 0;
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % open file to record data to
    i = Eyelink('Openfile', edfFile);
    if i~=0
        fprintf('Cannot create EDF file ''%s'' ', edffilename);
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end
    
    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
    [width, height]=Screen('WindowSize', screenid);
    
    %% SET UP EYELINK CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    % set parser (conservative saccade thresholds)
    
    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    
    % check the software version
    % add "HTARGET" to record possible target data for EyeLink Remote
    if sw_version >=4
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end
    
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && dummymode == 0
        fprintf('not connected, clean up\n');
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end
    
    %% Calibrate the eye tracker
    % setup the proper calibration foreground and background colors
    el.backgroundcolour = [125 125 125] ;
    el.calibrationtargetcolour = [255 255 255] ;
    
    % parameters are in frequency, volume, and duration
    % set the second value in each line to 0 to turn off the sound
    el.cal_target_beep=[600 0.5 0.05];
    el.drift_correction_target_beep=[600 0.5 0.05];
    el.calibration_failed_beep=[400 0.5 0.25];
    el.calibration_success_beep=[800 0.5 0.25];
    el.drift_correction_failed_beep=[400 0.5 0.25];
    el.drift_correction_success_beep=[800 0.5 0.25];
    
    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(el);
    
    % Hide the mouse cursor;
    Screen('HideCursorHelper', mainWindow);
    EyelinkDoTrackerSetup(el);
    
end


%% TRIAL LOOP

% preallocating columns for some variables that we want to save
RT = zeros(nTrials, 1);
pressedkey = zeros(nTrials, 1);
stimemotion = zeros(nTrials, 1);
segmentlength = zeros(nTrials, 1);
actor = zeros(nTrials, 1);
stimulusduration = zeros(nTrials, 1);
position = zeros(nTrials,1);
i = zeros(nTrials, 1);


for block = 1:nBlocks
    
    if block == 2
        
        % second repetition of stimuli - shuffle the structure
        myExpTrials = Shuffle(myExpTrials);
        
        % mid experiment break
        Screen('FillRect', mainWindow, bgColor);
        [vbl, ~, lastEventTime] = Screen('Flip', mainWindow);
        
        DrawFormattedText(mainWindow, breakInstructions, 'center', 'center', textColor);
        Screen('Flip', mainWindow, lastEventTime+ITI);
        waitForKb('space');
        
        FlushEvents('keyDown');
        Screen('FillRect', mainWindow, bgColor);
        Screen('Flip', mainWindow);
        
        
        % calibration half experiment
        if RunEyelinkCode
            
            el=EyelinkInitDefaults(mainWindow);
            if ~EyelinkInit(dummymode)
                fprintf('Eyelink Init aborted.\n');
                cleanup;  % cleanup function
                return;
            end
            
            % the following code is used to check the version of the eye tracker
            % and version of the host software
            sw_version = 0;
            
            [v vs]=Eyelink('GetTrackerVersion');
            fprintf('Running experiment on a ''%s'' tracker.\n', vs );
            
            % open file to record data to
            i = Eyelink('Openfile', edfFile);
            if i~=0
                fprintf('Cannot create EDF file ''%s'' ', edffilename);
                Eyelink( 'Shutdown');
                Screen('CloseAll');
                return;
            end
            
            Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
            [width, height]=Screen('WindowSize', screenid);
            
            %% SET UP EYELINK CONFIGURATION
            % Setting the proper recording resolution, proper calibration type,
            % as well as the data file content;
            Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
            Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
            % set calibration type.
            Eyelink('command', 'calibration_type = HV9');
            % set parser (conservative saccade thresholds)
            
            % set EDF file contents using the file_sample_data and
            % file-event_filter commands
            % set link data thtough link_sample_data and link_event_filter
            Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
            Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
            
            % check the software version
            % add "HTARGET" to record possible target data for EyeLink Remote
            if sw_version >=4
                Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
                Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
            else
                Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
                Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
            end
            
            % allow to use the big button on the eyelink gamepad to accept the
            % calibration/drift correction target
            Eyelink('command', 'button_function 5 "accept_target_fixation"');
            
            
            % make sure we're still connected.
            if Eyelink('IsConnected')~=1 && dummymode == 0
                fprintf('not connected, clean up\n');
                Eyelink( 'Shutdown');
                Screen('CloseAll');
                return;
            end
            
            %% Calibrate the eye tracker
            % setup the proper calibration foreground and background colors
            el.backgroundcolour = [125 125 125] ;
            el.calibrationtargetcolour = [255 255 255] ;
            
            % parameters are in frequency, volume, and duration
            % set the second value in each line to 0 to turn off the sound
            el.cal_target_beep=[600 0.5 0.05];
            el.drift_correction_target_beep=[600 0.5 0.05];
            el.calibration_failed_beep=[400 0.5 0.25];
            el.calibration_success_beep=[800 0.5 0.25];
            el.drift_correction_failed_beep=[400 0.5 0.25];
            el.drift_correction_success_beep=[800 0.5 0.25];
            
            % you must call this function to apply the changes from above
            EyelinkUpdateDefaults(el);
            
            % Hide the mouse cursor;
            Screen('HideCursorHelper', mainWindow);
            EyelinkDoTrackerSetup(el);
            
        end
    end
    
    
    for trial = 1:nTrials
        
        
        %% EYELINK
        if RunEyelinkCode
            
            %Eyelink('Message', 'TRIALID %d', trial);
            % This supplies the title at the bottom of the eyetracker display
            Eyelink('command', 'record_status_message "TRIAL %d/%d "', trial, 3);
            % Before recording, we place reference graphics on the host display
            % Must be offline to draw to EyeLink screen
            Eyelink('Command', 'set_idle_mode');
            % clear tracker display and draw box at center
            Eyelink('Command', 'clear_screen 0')
            Eyelink('command', 'draw_box %d %d %d %d 15', width/2-50, height/2-50, width/2+50, height/2+50);
            % TO BE CORRECTED @@@@@@@@@@@@@@@@@@@@@@@@@
            
            % Do a drift correction at the beginning of each trial
            % Performing drift correction (checking) is optional for
            % EyeLink 1000 eye trackers.
            %         EyelinkDoDriftCorrection(el); %pour s'assurer que le participant
            %         regarde bien la croix de fixation.
            
            % start recording eye position (preceded by a short pause so that
            % the tracker can finish the mode transition)
            % The paramerters for the 'StartRecording' call controls the
            % file_samples, file_events, link_samples, link_events availability
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            
            
            %% Eyelink start recording
            Eyelink('StartRecording');
            WaitSecs(0.05); % SET HOW MUCH TIME YOU WANT BEFORE THE SCRIPT CONTINUES TO YOUR STIMULI
            
            %Message to mark the trial onset
            Eyelink('Message', 'SYNCTIME'); % to mark the beginning of the trial
            
        end
        
        
        % select structure for current stimulus
        currentStimulus = myExpTrials(trial).stimuli;
        
        % random jitter
        j = jitter(randperm(3));
        
        % inter-block breaks
        if mod(trial, nTrials/4) == 0
            
            if trial < nTrials
                
                Screen('FillRect', mainWindow, bgColor);
                [vbl, ~, lastEventTime] = Screen('Flip', mainWindow);
                
                DrawFormattedText(mainWindow, breakInstructions, 'center', 'center', textColor);
                Screen('Flip', mainWindow, lastEventTime+ITI);
                waitForKb('space');
                
                FlushEvents('keyDown');
                Screen('FillRect', mainWindow, bgColor);
                Screen('Flip', mainWindow);
                
                % calibration after break
                if RunEyelinkCode
                    
                    el=EyelinkInitDefaults(mainWindow);
                    if ~EyelinkInit(dummymode)
                        fprintf('Eyelink Init aborted.\n');
                        cleanup;  % cleanup function
                        return;
                    end
                    
                    % the following code is used to check the version of the eye tracker
                    % and version of the host software
                    sw_version = 0;
                    
                    [v vs]=Eyelink('GetTrackerVersion');
                    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
                    
                    % open file to record data to
                    i = Eyelink('Openfile', edfFile);
                    if i~=0
                        fprintf('Cannot create EDF file ''%s'' ', edffilename);
                        Eyelink( 'Shutdown');
                        Screen('CloseAll');
                        return;
                    end
                    
                    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
                    [width, height]=Screen('WindowSize', screenid);
                    
                    %% SET UP EYELINK CONFIGURATION
                    % Setting the proper recording resolution, proper calibration type,
                    % as well as the data file content;
                    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
                    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
                    % set calibration type.
                    Eyelink('command', 'calibration_type = HV9');
                    % set parser (conservative saccade thresholds)
                    
                    % set EDF file contents using the file_sample_data and
                    % file-event_filter commands
                    % set link data thtough link_sample_data and link_event_filter
                    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
                    
                    % check the software version
                    % add "HTARGET" to record possible target data for EyeLink Remote
                    if sw_version >=4
                        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
                        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
                    else
                        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
                        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
                    end
                    
                    % allow to use the big button on the eyelink gamepad to accept the
                    % calibration/drift correction target
                    Eyelink('command', 'button_function 5 "accept_target_fixation"');
                    
                    
                    % make sure we're still connected.
                    if Eyelink('IsConnected')~=1 && dummymode == 0
                        fprintf('not connected, clean up\n');
                        Eyelink( 'Shutdown');
                        Screen('CloseAll');
                        return;
                    end
                    
                    %% Calibrate the eye tracker
                    % setup the proper calibration foreground and background colors
                    el.backgroundcolour = [125 125 125] ;
                    el.calibrationtargetcolour = [255 255 255] ;
                    
                    % parameters are in frequency, volume, and duration
                    % set the second value in each line to 0 to turn off the sound
                    el.cal_target_beep=[600 0.5 0.05];
                    el.drift_correction_target_beep=[600 0.5 0.05];
                    el.calibration_failed_beep=[400 0.5 0.25];
                    el.calibration_success_beep=[800 0.5 0.25];
                    el.drift_correction_failed_beep=[400 0.5 0.25];
                    el.drift_correction_success_beep=[800 0.5 0.25];
                    
                    % you must call this function to apply the changes from above
                    EyelinkUpdateDefaults(el);
                    
                    % Hide the mouse cursor;
                    Screen('HideCursorHelper', mainWindow);
                    EyelinkDoTrackerSetup(el);
                    
                end
                
            end
        end
        
        
        
        
        % set the screen to background color
        Screen('FillRect', mainWindow, bgColor);
        [~, ~, lastEventTime] = Screen('Flip', mainWindow);
        
        % draw fixation cross
        Screen('DrawLines', mainWindow, fixationXY, lineSizePix, fixColor);
        [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+ITI);
        
        % time stamp for frame presentation
        Screen('FillRect', mainWindow, bgColor);
        [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+fixationDur+j(1));
        
        % frames presentation loop
        for g = 1:myExpTrials(trial).gate
            Screen('DrawTexture', mainWindow, currentStimulus(g).imageTexture, [], myExpTrials(trial).position, 0);
            Screen('DrawLines', mainWindow, fixationXY, lineSizePix, fixColor);
            [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
            
            % time stamp to measure stimulus duration on screen
            if g == 1
                beginStimulus = GetSecs;
            end
            
        end
        
        
        % after stimulus presentation
        
        % draw question mark and flip it to the screen
        DrawFormattedText(mainWindow, questionMark, 'center', 'center', white);
        [vlb, sTime, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
        
        
        % time stamp for RT and stimulus measurement - start measuring RTs from here
        % it's also the en-of-stimulus time stamp
        tStart = GetSecs;
        
        
        %% EYELINK  - STOP RECORDING
        if RunEyelinkCode
            
            Eyelink('Message', 'BLANK_SCREEN');
            % adds 100 msec of data to catch final events
            WaitSecs(0.1);
            % stop the recording of eye-movements for the current trial
            Eyelink('StopRecording');
        end
        
        
        % while loop waiting for a keypress
        t1 = 0;
        while t1 < responseDur
            [keyIsDown, time, key] = KbCheck;
            
            if keyIsDown
                RT(trial) = (GetSecs - tStart)*1000;
                break
            end
            
            t2 = GetSecs;
            t1 = t2 - vlb;
            
        end
        
        
        % escape loop with Q button
        if strcmp(KbName(find(key)),'q')
            ListenChar;
            sca;
            fclose all;
            ShowCursor;
        else
            % if the pressed key is different from Q
            pressedKey = KbName(KbName(find(key)));
        end
        
        
        % if no keypress is reported, assign value 999
        if numel(pressedKey) ~= 0
            pressedKey = pressedKey(1);
        else
            pressedKey = 999;
        end
        
        % find matching between the key pressed by the subject and the
        % response keys defined earlier.
        % If the subject did not press any of the given keys,
        % trialResponseKey will be empty; otherwise it will return a vector
        % with the poition, in answerKeys, of the found correspondece
        trialResponseKey = find(answerKeys == pressedKey);
        
        % careful with mapping keys and emotions here!!
        % (to be changed if a 5th emoyion is added)
        
        if trialResponseKey == 1
            pressedkey(trial) = 3; % 'C' has been pressed % 3 = FEAR
        elseif trialResponseKey == 2
            pressedkey(trial) = 1; % 'V' has been pressed % 1 = ANGER
        elseif trialResponseKey == 3
            pressedkey(trial) = 2; % 'B' has been pressed % 2 = DISGUST
        elseif trialResponseKey == 4
            pressedkey(trial) = 4; % 'N' has been pressed % 4 = JOY
        end
        
        if isempty(trialResponseKey) == 1
            if pressedKey == 999
                pressedkey(trial) = 999; % time was out and no response given
                
                % time out feedback
                feedbackMessage = 'Time out!';
                DrawFormattedText(mainWindow, feedbackMessage, 'center', 'center', textColor);
                Screen('Flip', mainWindow);
                WaitSecs(0.5);
                
            else
                pressedkey(trial) = 888; % the response did not correspond to any of the given keys
                
                % wrong key press feedback
                feedbackMessage = 'Invalid key!';
                DrawFormattedText(mainWindow, feedbackMessage, 'center', 'center', textColor);
                Screen('Flip', mainWindow);
                WaitSecs(0.5);
                
            end
        end
        
        % emotion can assume a value between 1 and 5
        % right now: 1 - anger
        % 2 - disgust
        % 3 - fear
        % 4 - happiness
        % 5 - sadness
        stimemotion(trial) = myExpTrials(trial).emotion;
        
        % segment length varies between 1 and 10
        % 1 - the shortest segments (3 frames)
        % 10 - the longest segments (12 frames)
        segmentlength(trial) = myExpTrials(trial).gate;
        
        % position can assume the value of 1, 2 or 3
        % 1 - upper
        % 2 - central
        % 3 - lower
        if myExpTrials(trial).location == 1
            position(trial) = 1;
        elseif myExpTrials(trial).location == 2
            position(trial) = 2;
        elseif myExpTrials(trial).location == 3
            position(trial) = 3;
        end
        
        % actor can assume values 1, 2, 3 or 4
        % 1 - actress 25
        % 2 - actress 26
        % 3 - actor 32
        % 4 - actor 33
        actor(trial) = myExpTrials(trial).actor;
        
        % stimulus duration
        stimulusduration(trial) = tStart - beginStimulus;
        
        % a variable that assumes value 1 if the subject answers
        % correctly, a value of 0 if it answered incorrectly
        if stimemotion(trial) == pressedkey(trial)
            i(trial) = 1;
        else
            i(trial) = 0;
        end
        
        % SAVE DATA TO THE OUTPUT FILE
        dataFile = fopen(dataFileName, 'a');
        fprintf(dataFile, formatString, block, trial, actor(trial), [segmentlength(trial)-2], stimemotion(trial), position(trial), pressedkey(trial), i(trial), RT(trial), stimulusduration(trial));
        fclose(dataFile);
        
    end
    
end


%% End of the experiment %%
% press any key to leave PTB

DrawFormattedText(mainWindow, goodbyeMessage, 'center', 'center', textColor);
Screen('Flip', mainWindow, lastEventTime+ITI);
KbStrokeWait;


%% EYE TRACKER - SHUTDOWN [ SHOULD BE AT THE END OF YOUR SCRIPT]
% STEP 9
% close the eye tracker and window
if RunEyelinkCode
    Eyelink('ShutDown');
end

% end of experiment
ListenChar(0);
Priority(0);
ShowCursor;
sca;