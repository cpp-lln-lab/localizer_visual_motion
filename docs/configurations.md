# Configurations

- [Configurations](#configurations)
  - [For MT localiser](#for-mt-localiser)
  - [Let the scanner pace the experiment](#let-the-scanner-pace-the-experiment)

## For MT localiser

These are all the options that can be tweaked.

```matlab
cfg.aperture.type =	'none';
cfg.aperture.width =	[];
cfg.aperture.xPos =	0.000000;
cfg.audio.do =	0;
cfg.bids.MRI.Instructions =	'1-Detect the RED fixation cross';
cfg.bids.MRI.TaskDescription =	'';
cfg.bids.mri.RepetitionTime =	[];
cfg.color.background =	0.000000, 0.000000, 0.000000;
cfg.color.black =	0.000000, 0.000000, 0.000000;
cfg.color.blue =	0.000000, 255.000000, 0.000000;
cfg.color.green =	0.000000, 0.000000, 255.000000;
cfg.color.grey =	127.500000, 127.500000, 127.500000;
cfg.color.red =	255.000000, 0.000000, 0.000000;
cfg.color.white =	255.000000, 255.000000, 255.000000;
cfg.debug.do =	1;
cfg.debug.smallWin =	1;
cfg.debug.transpWin =	1;
cfg.design.localizer =	'MT';
cfg.design.motionDirections =	0.000000, 0.000000, 180.000000, 180.000000;
cfg.design.motionType =	'translation';
cfg.design.names{1} =	'static';
cfg.design.names{2} =	'motion';
cfg.design.nbEventsPerBlock =	12.000000;
cfg.design.nbRepetitions =	12.000000;
cfg.dot.coherence =	1.000000;
cfg.dot.color =	255.000000, 255.000000, 255.000000;
cfg.dot.density =	1.000000;
cfg.dot.lifeTime =	0.400000;
cfg.dot.proportionKilledPerFrame =	0.000000;
cfg.dot.size =	0.200000;
cfg.dot.speed =	15.000000;
cfg.dot.staticReSeed =	1;
cfg.extraColumns{1} =	'direction';
cfg.extraColumns{2} =	'speedDegVA';
cfg.extraColumns{3} =	'target';
cfg.extraColumns{4} =	'event';
cfg.extraColumns{5} =	'block';
cfg.extraColumns{6} =	'keyName';
cfg.extraColumns{7} =	'fixationPosition';
cfg.extraColumns{8} =	'aperturePosition';
cfg.eyeTracker.do =	0;
cfg.fixation.color =	255.000000, 255.000000, 255.000000;
cfg.fixation.colorTarget =	255.000000, 0.000000, 0.000000;
cfg.fixation.lineWidthPix =	3.000000;
cfg.fixation.type =	'cross';
cfg.fixation.width =	0.250000;
cfg.fixation.xDisplacement =	0.000000;
cfg.fixation.yDisplacement =	0.000000;
cfg.hideCursor =	0;
cfg.keyboard.escapeKey =	'ESCAPE';
cfg.keyboard.keyboard =	[];
cfg.keyboard.responseBox =	[];
cfg.keyboard.responseKey{1} =	'r';
cfg.keyboard.responseKey{2} =	'g';
cfg.keyboard.responseKey{3} =	'y';
cfg.keyboard.responseKey{4} =	'b';
cfg.keyboard.responseKey{5} =	'd';
cfg.keyboard.responseKey{6} =	'n';
cfg.keyboard.responseKey{7} =	'z';
cfg.keyboard.responseKey{8} =	'e';
cfg.keyboard.responseKey{9} =	't';
cfg.mri.repetitionTime =	1.800000;
cfg.mri.triggerKey =	't';
cfg.mri.triggerNb =	5.000000;
cfg.pacedByTriggers.do =	0;
cfg.screen.monitorDistance =	95.000000;
cfg.screen.monitorWidth =	25.000000;
cfg.screen.resolution{1} =	[];
cfg.screen.resolution{2} =	[];
cfg.screen.resolution{3} =	[];
cfg.skipSyncTests =	1.000000;
cfg.suffix.acquisition =	'';
cfg.target.duration =	0.100000;
cfg.target.maxNbPerBlock =	1.000000;
cfg.target.type =	'fixation_cross';
cfg.task.instruction =	'1-Detect the RED fixation cross';
cfg.task.name =	'visual localizer';
cfg.task.taskDescription =	'';
cfg.testingDevice =	'mri';
cfg.text.color =	255.000000, 255.000000, 255.000000;
cfg.text.font =	'Courier New';
cfg.text.size =	18.000000;
cfg.text.style =	1.000000;
cfg.timing.IBI =	4.000000;
cfg.timing.ISI =	0.100000;
cfg.timing.endDelay =	5.000000;
cfg.timing.eventDuration =	0.300000;
cfg.timing.onsetDelay =	5.000000;
cfg.verbose =	1.000000;
```

##

Type help `expDesign` to get information on how to tweak your experiment design.

## Let the scanner pace the experiment

<!-- TODO check that this is still valid -->

Set `cfg.pacedByTriggers.do` to `true` and you can then set all the details in
this `if` block

```matlab
% Time is here in terms of `repetition time (TR)` (i.e. MRI volumes)
if cfg.pacedByTriggers.do

  cfg.pacedByTriggers.quietMode = true;
  cfg.pacedByTriggers.nbTriggers = 1;

  cfg.timing.eventDuration = cfg.mri.repetitionTime / 2 - 0.04; % second

  % Time between blocs in secs
  cfg.timing.IBI = 0;
  % Time between events in secs
  cfg.timing.ISI = 0;
  % Number of seconds before the motion stimuli are presented
  cfg.timing.onsetDelay = 0;
  % Number of seconds after the end all the stimuli before ending the run
  cfg.timing.endDelay = 2;

end
```
