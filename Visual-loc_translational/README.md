# Translational Motion

## Requirements

Make sure that the following toolboxes are installed and added to the matlab / octave path.

For instructions see the following links:

| Requirements                                             | Used version |
|----------------------------------------------------------|--------------|
| [CPP_BIDS](https://github.com/cpp-lln-lab/CPP_BIDS)      | ?            |
| [CPP_PTB](https://github.com/cpp-lln-lab/CPP_PTB)        | ?            |
| [PsychToolBox](http://psychtoolbox.org/)                 | >=3.0.14     |
| [Matlab](https://www.mathworks.com/products/matlab.html) | >=2017      |
| or [octave](https://www.gnu.org/software/octave/)        | >=4.?        |

## Installing dependencies

All the dependencies needed to run this are listed in the [mpm-requirements.txt file](.mpm-requirements.txt). If those functions are not in the matlab path the scripts in this repository will not work.

If you are using the [matlab package manager](https://github.com/mobeets/mpm), you can simply download the appropriate version of those dependencies and add them to your path by running the `getDependencies` function.

```matlab
getDependencies('update')
```

If you already have the appropriate version but just want to add them to the matlab path, then run.

```matlab
getDependencies()
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

### subfun/doDotMo

#### Input:
- `cfg`: PTB/machine configurations returned by `setParameters` and `initPTB`
- `expParameters`: parameters returned by `setParameters`
- `logFile`: structure that stores the experiment logfile to be saved

#### Output:
- Event `onset`
- Event `duration`

The dots are drawn on a square that contains the round aperture, then any dots outside of the aperture is turned into a NaN so effectively the actual number of dots on the screen at any given time is not the one that you input but a smaller number (nDots / Area of aperture) on average.

### subfun/expDesign
Creates the sequence of blocks and the events in them. The conditions are consecutive static and motion blocks (Gives better results than randomised). It can be run as a stand alone without inputs to display a visual example of possible design.

#### EVENTS
The `numEventsPerBlock` should be a multiple of the number of "base" listed in the `motionDirections` and `staticDirections` (4 at the moment).

#### TARGETS:
- If there are 2 targets per block we make sure that they are at least 2 events apart.
- Targets cannot be on the first or last event of a block

#### Input:
- `expParameters`: parameters returned by `setParameters`
- `displayFigs`: a boolean to decide whether to show the basic design matrix of the design

#### Output:
- `expParameters.designBlockNames` is a cell array `(nr_blocks, 1)` with the name for each block
- `expParameters.designDirections` is an array `(nr_blocks, numEventsPerBlock)` with the direction to present in a given block
  - `0 90 180 270` indicate the angle
  - `-1` indicates static
- `expParameters.designSpeeds` is an array `(nr_blocks, numEventsPerBlock) * speedEvent`
- `expParameters.designFixationTargets` is an array `(nr_blocks, numEventsPerBlock)` showing for each event if it should be accompanied by a target

### subfun/eyeTracker
Eyetracker script, still to be debugged. Will probably moved in the CPP_PTB package. It deals with the calibration (dufault or custom), eye movements recording and saving the files.

### subfun/wait4Trigger
Simple functions that counts the triggers sent by the MRI computer to the stimulation computer to sync brain volume recordings and stimulation.
