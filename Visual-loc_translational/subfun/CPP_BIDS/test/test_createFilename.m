% test for filename creation and their directories

% add parent folder to the parth
addpath(genpath(fullfile(fileparts(mfilename), '..')))


%% check directory and filename creation (PC and eyetracker)

clear

expParameters.subjectGrp = '';
expParameters.subjectNb = 1;
expParameters.sessionNb = 1;
expParameters.runNb = 1;
expParameters.task = 'testtask';

cfg.eyeTracker = true;
cfg.device = 'PC';

expParameters = checkCFG(expParameters);
expParameters = createFilename(expParameters, cfg);

outputDir = fullfile(pwd, ...
    '..', '..', ...
    'output', 'source', 'sub-001', 'ses-001', 'beh');

eyetrackerDir = fullfile(pwd, ...
    '..', '..', ...
    'output', 'source', 'sub-001', 'ses-001', 'eyetracker');


assert(exist(outputDir, 'dir')==7)
assert(exist(eyetrackerDir, 'dir')==7)
assert(strcmp(...
              expParameters.fileName.events, ...
              ['sub-001_ses-001_task-testtask_run-001_events_date-' expParameters.date '.tsv']));
assert(strcmp(...
              expParameters.fileName.eyetracker, ...
              ['sub-001_ses-001_task-testtask_run-001_eyetrack_date-' expParameters.date '.edf']));


%% check directory and filename creation (fMRI)

clear

expParameters.subjectGrp = 'ctrl';
expParameters.subjectNb = 2;
expParameters.sessionNb = 2;
expParameters.runNb = 2;
expParameters.task = 'testtask';

cfg.eyeTracker = false;
cfg.device = 'scanner';

expParameters = checkCFG(expParameters);
expParameters = createFilename(expParameters, cfg);

outputDir = fullfile(pwd, ...
    '..', '..', ...
    'output', 'source', 'sub-ctrl002', 'ses-002', 'func');

eyetrackerDir = fullfile(pwd, ...
    '..', '..', ...
    'output', 'source', 'sub-ctrl002', 'ses-002', 'eyetracker');


assert(exist(outputDir, 'dir')==7)
assert(strcmp(expParameters.fileName.base, 'sub-ctrl002_ses-002_task-testtask'))
assert(strcmp(...
              expParameters.fileName.events, ...
              ['sub-ctrl002_ses-002_task-testtask_run-002_events_date-' expParameters.date '.tsv']));

