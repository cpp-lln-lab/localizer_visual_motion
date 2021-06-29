[![](https://img.shields.io/badge/Octave-CI-blue?logo=Octave&logoColor=white)](https://github.com/cpp-lln-lab/localizer_visual_motion/actions)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
![](https://github.com/cpp-lln-lab/localizer_visual_motion/workflows/CI/badge.svg)

[![codecov](https://codecov.io/gh/cpp-lln-lab/localizer_visual_motion/branch/master/graph/badge.svg)](https://codecov.io/gh/cpp-lln-lab/localizer_visual_motion)

[![Build Status](https://travis-ci.com/cpp-lln-lab/localizer_visual_motion.svg?branch=master)](https://travis-ci.com/cpp-lln-lab/localizer_visual_motion)

<!-- TOC -->
- [fMRI localizers for visual motion](#fmri-localizers-for-visual-motion)
  - [Translational Motion](#translational-motion)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Structure and function details](#structure-and-function-details)
    - [visualLocTranslational](#visualloctranslational)
    - [setParameters](#setparameters)
      - [Let the scanner pace the experiment](#let-the-scanner-pace-the-experiment)
    - [subfun/doDotMo](#subfundodotmo)
      - [Input](#input)
      - [Output](#output)
    - [subfun/expDesign](#subfunexpdesign)
      - [EVENTS](#events)
      - [TARGETS](#targets)
      - [Input](#input-1)
      - [Output](#output-1)
<!-- TOC -->

# fMRI localizers for visual motion

## Translational Motion

## Requirements

Make sure that the following toolboxes are installed and added to the matlab / octave path.

For instructions see the following links:

| Requirements                                             | Used version |
| -------------------------------------------------------- | ------------ |
| [CPP_BIDS](https://github.com/cpp-lln-lab/CPP_BIDS)      | ?            |
| [CPP_PTB](https://github.com/cpp-lln-lab/CPP_PTB)        | ?            |
| [PsychToolBox](http://psychtoolbox.org/)                 | >=3.0.14     |
| [Matlab](https://www.mathworks.com/products/matlab.html) | >=2017       |
| or [octave](https://www.gnu.org/software/octave/)        | >=4.?        |

## Installation

The CPP_BIDS and CPP_PTB dependencies are already set up as submodule to this repository.
You can install it all with git by doing.

```bash
git clone --recurse-submodules https://github.com/cpp-lln-lab/localizer_visual_motion.git
```

## Structure and function details

### visualLocTranslational

Running this script will show blocks of motion dots (soon also moving gratings) and static dots. Motion blocks will show dots(/gratings) moving in one of four directions (up-, down-, left-, and right-ward)

By default it is run in `Debug mode` meaning that it does not run care about subjID, run n., fMRI triggers, Eye Tracker, etc..

Any details of the experiment can be changed in `setParameters.m` (e.g., experiment mode, motion stimuli details, exp. design, etc.)

### setParameters

`setParameters.m` is the core engine of the experiment. It contains the following tweakable sections:

- Debug mode setting
- MRI settings
- Engine parameters:
  - Monitor parameters
  - Monitor parameters for PsychToolBox
- Keyboards
- Experiment Design
- Visual Stimulation
- Task(s)
  - Instructions
  - Task #1 parameters

#### Let the scanner pace the experiment

Set `cfg.pacedByTriggers.do` to `true` and you can then set all the details in this `if` block

```matlab
% Time is here in in terms of number repetition time (i.e MRI volumes)
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

### subfun/doDotMo

#### Input

- `cfg`: PTB/machine configurations returned by `setParameters` and `initPTB`
- `expParameters`: parameters returned by `setParameters`
- `logFile`: structure that stores the experiment logfile to be saved

#### Output

- Event `onset`
- Event `duration`

The dots are drawn on a square that contains the round aperture, then any dots outside of the aperture is turned into a NaN so effectively the actual number of dots on the screen at any given time is not the one that you input but a smaller number (nDots / Area of aperture) on average.

### subfun/expDesign

Creates the sequence of blocks and the events in them. The conditions are consecutive static and motion blocks (Gives better results than randomised). It can be run as a stand alone without inputs to display a visual example of possible design.

#### EVENTS

The `numEventsPerBlock` should be a multiple of the number of "base" listed in the `motionDirections` and `staticDirections` (4 at the moment).

#### TARGETS

- If there are 2 targets per block we make sure that they are at least 2 events apart.
- Targets cannot be on the first or last event of a block

#### Input

- `expParameters`: parameters returned by `setParameters`
- `displayFigs`: a boolean to decide whether to show the basic design matrix of the design

#### Output

- `expParameters.designBlockNames` is a cell array `(nr_blocks, 1)` with the name for each block
- `expParameters.designDirections` is an array `(nr_blocks, numEventsPerBlock)` with the direction to present in a given block
  - `0 90 180 270` indicate the angle
  - `-1` indicates static
- `expParameters.designSpeeds` is an array `(nr_blocks, numEventsPerBlock) * speedEvent`
- `expParameters.designFixationTargets` is an array `(nr_blocks, numEventsPerBlock)` showing for each event if it should be accompanied by a target

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/mohmdrezk"><img src="https://avatars2.githubusercontent.com/u/9597815?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mohamed Rezk</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/localizer_visual_motion/commits?author=mohmdrezk" title="Code">💻</a> <a href="#design-mohmdrezk" title="Design">🎨</a> <a href="#ideas-mohmdrezk" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/marcobarilari"><img src="https://avatars3.githubusercontent.com/u/38101692?v=4?s=100" width="100px;" alt=""/><br /><sub><b>marcobarilari</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/localizer_visual_motion/commits?author=marcobarilari" title="Code">💻</a> <a href="#design-marcobarilari" title="Design">🎨</a> <a href="#ideas-marcobarilari" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/cpp-lln-lab/localizer_visual_motion/issues?q=author%3Amarcobarilari" title="Bug reports">🐛</a> <a href="#userTesting-marcobarilari" title="User Testing">📓</a> <a href="https://github.com/cpp-lln-lab/localizer_visual_motion/pulls?q=is%3Apr+reviewed-by%3Amarcobarilari" title="Reviewed Pull Requests">👀</a> <a href="#question-marcobarilari" title="Answering Questions">💬</a> <a href="#infra-marcobarilari" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-marcobarilari" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://remi-gau.github.io/"><img src="https://avatars3.githubusercontent.com/u/6961185?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Remi Gau</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/localizer_visual_motion/commits?author=Remi-Gau" title="Code">💻</a> <a href="#design-Remi-Gau" title="Design">🎨</a> <a href="#ideas-Remi-Gau" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/cpp-lln-lab/localizer_visual_motion/issues?q=author%3ARemi-Gau" title="Bug reports">🐛</a> <a href="#userTesting-Remi-Gau" title="User Testing">📓</a> <a href="https://github.com/cpp-lln-lab/localizer_visual_motion/pulls?q=is%3Apr+reviewed-by%3ARemi-Gau" title="Reviewed Pull Requests">👀</a> <a href="#question-Remi-Gau" title="Answering Questions">💬</a> <a href="#infra-Remi-Gau" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-Remi-Gau" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/CerenB"><img src="https://avatars1.githubusercontent.com/u/10451654?v=4?s=100" width="100px;" alt=""/><br /><sub><b>CerenB</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/localizer_visual_motion/issues?q=author%3ACerenB" title="Bug reports">🐛</a> <a href="#userTesting-CerenB" title="User Testing">📓</a></td>
    <td align="center"><a href="https://github.com/iqrashahzad14"><img src="https://avatars.githubusercontent.com/u/75671348?v=4?s=100" width="100px;" alt=""/><br /><sub><b>iqrashahzad14</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/localizer_visual_motion/commits?author=iqrashahzad14" title="Code">💻</a> <a href="#ideas-iqrashahzad14" title="Ideas, Planning, & Feedback">🤔</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
