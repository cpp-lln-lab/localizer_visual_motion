# Translational Motion

## Requirements

Make sure that the following toolboxes are installed and added to the matlab / octave path.

For instructions see the following links:

| Requirements                                             | Used version |
|----------------------------------------------------------|--------------|
| [CPP_BIDS](https://github.com/cpp-lln-lab/CPP_BIDS)      | ?            |
| [CPP_PTB](https://github.com/cpp-lln-lab/CPP_PTB)        | ?            |
| [PsychToolBox](http://psychtoolbox.org/)                 | >=3.0.14     |
| [Matlab](https://www.mathworks.com/products/matlab.html) | >=20117      |
| or [octave](https://www.gnu.org/software/octave/)        | >=4.?        |

## Installing dependencies

All the dependencies needed to run this are listed in the [mpm-requirements.txt file](.mpm-requirements.txt). If those functions are not in the matlab path the scripts in this repository will not work.

If you are using the [matlab package manager](https://github.com/mobeets/mpm), you can simply download the appropriate version of those dependencies and add them to your path by running the `getDependencies` function.

```matlab
getDependencies('update')
```

If you only already have the appropriate version but just want to add them to the matlab path, then run.

```matlab
getDependencies()
```
## Structure and function details

### visualLocTranslational

### setParameters

### subfun/doDotMo

### subfun/expDesign

### subfun/eyeTracker

### subfun/wait4Trigger
