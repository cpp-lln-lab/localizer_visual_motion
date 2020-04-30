% test for events.tsv file creation

% add parent folder to the parth
addpath(genpath(fullfile(fileparts(mfilename), '..')))


%% set up

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



%% create the file

logFile = saveEventsFile('open', expParameters, [], 'Speed', 'is_Fixation');


% ---- test section

fileName = fullfile(expParameters.outputDir, expParameters.modality, expParameters.fileName.events);

% check that the file has the right path and name
assert(exist(fileName, 'file')==2)



%%  write things in it

logFile(1).onset = 1;
logFile(1).trial_type = 'motion_up';
logFile(1).duration = 1;
logFile(1).speed = [];
logFile(1).is_fixation = 'true';

saveEventsFile('save', expParameters, logFile, 'speed', 'is_fixation');


logFile(1,1).onset = 2;
logFile(1,1).trial_type = 'motion_up';
logFile(1,1).duration = 1;
logFile(1,1).speed = 2;
logFile(1,1).is_fixation = true;

logFile(2,1).onset = 3;
logFile(2,1).trial_type = 'static';
logFile(2,1).duration = 4;
logFile(2,1).is_fixation = 3;

saveEventsFile('save', expParameters, logFile, 'speed', 'is_fixation');


% close the file
saveEventsFile('close', expParameters, logFile);


% ---- test section

% check the extra columns of the header and some of the content

FID = fopen(fileName, 'r');
C = textscan(FID,'%s%s%s%s%s','Delimiter', '\t', 'EndOfLine', '\n');

assert(isequal(C{4}{1}, 'speed')); % check header

assert(isequal(C{4}{2}, 'NaN')); % check that empty values are entered as NaN
assert(isequal(C{4}{4}, 'NaN')); % check that missing fields are entered as NaN

assert(isequal(str2num(C{5}{4}), 3)); % check values entered properly
