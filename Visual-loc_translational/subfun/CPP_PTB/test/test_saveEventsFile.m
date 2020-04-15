% test for events.tsv file creation

% add parent folder to the parth
addpath(genpath(fullfile(fileparts(mfilename), '..')))


%% check file creation and its content

% ---- set up section

clear

expParameters.subjectGrp = '';
expParameters.subjectNb = 1;
expParameters.sessionNb = 1;
expParameters.runNb = 1;
expParameters.task = 'testtask';

cfg.eyeTracker = false;
cfg.device = 'scanner';

expParameters = checkCFG(expParameters);
expParameters = createFilename(expParameters, cfg);



% create the file
logFile = saveEventsFile('open', expParameters, [], 'Speed', 'is_Fixation');


% write things in it
logFile.onset = {1};
logFile.trial_type = {'motion_up'};
logFile.duration = {1};
logFile.speed = {[]};
logFile.is_fixation = {'true'};

logFile = saveEventsFile('save', expParameters, logFile, 'speed', 'is_fixation');


logFile.onset = {2; 3};
logFile.trial_type = {'motion_up'; 'static'};
logFile.duration = {1; 4};
logFile.speed = {2; 4};
logFile.is_fixation = {'true'; 3};

logFile = saveEventsFile('save', expParameters, logFile, 'speed', 'is_fixation');


% close the file
saveEventsFile('close', expParameters, logFile);





% ---- test section

fileName = fullfile(expParameters.outputDir, expParameters.fileName.events);

% check that the file has the right path and name
assert(exist(fileName, 'file')==2)

% check that the right fields are created
assert(isfield(logFile, 'speed'));
assert(isfield(logFile, 'is_fixation'));

% check the extra columns of the header and some of the content
FID = fopen(fileName, 'r');
C = textscan(FID,'%s%s%s%s%s','Delimiter', '\t', 'EndOfLine', '\n');
assert(isequal(C{4}{1}, 'speed'));
assert(isequal(C{4}{2}, 'NaN'));
assert(isequal(str2num(C{5}{4}), 3));