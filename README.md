[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5866130.svg)](https://doi.org/10.5281/zenodo.5866130)
[![](https://img.shields.io/badge/Octave-CI-blue?logo=Octave&logoColor=white)](https://github.com/cpp-lln-lab/localizer_visual_motion/actions/workflows/moxunit.yml))
[![codecov](https://codecov.io/gh/cpp-lln-lab/localizer_visual_motion/branch/master/graph/badge.svg)](https://codecov.io/gh/cpp-lln-lab/localizer_visual_motion)
[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors-)

- [fMRI localizers for visual motion](#fmri-localizers-for-visual-motion)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Set up and running](#set-up-and-running)
  - [Contributors ✨](#contributors-)

# fMRI localizers for visual motion

Running this script will show blocks of motion dots and static dots. Motion
blocks will show:

- dots moving in one of four directions (up-, down-, left-, and right-ward) (MT+
  localizer)
- or dots moving inward and outward in the peripheral of the screen (MT/MST
  localizer).

## Requirements

Make sure that the following toolboxes are installed and added to the matlab /
octave path. See the next section on how to install the submodule toolboxes.

For instructions see the following links:

| Requirements                                                    | Used version |
| --------------------------------------------------------------- | ------------ |
| [CPP_BIDS](https://github.com/cpp-lln-lab/CPP_BIDS) (submodule) | 2.1.1        |
| [CPP_PTB](https://github.com/cpp-lln-lab/CPP_PTB) (submodule)   | 1.2.1        |
| [PsychToolBox](http://psychtoolbox.org/)                        | >=3.0.14     |
| [Matlab](https://www.mathworks.com/products/matlab.html)        | >=2017       |
| or [octave](https://www.gnu.org/software/octave/)               | >=4.?        |

## Installation

The CPP_BIDS and CPP_PTB dependencies are already set up as submodules to this
repository. You can install it all with git by doing.

```bash
git clone --recurse-submodules https://github.com/cpp-lln-lab/localizer_visual_motion.git
```

## Set up and running

In the `main.m` script, you are meant

- to set your configuration (`cfg`)
- call `initEnv()` to add the relevant folders to the MATLAB path
- call `cfg = checkParameters(cfg)` to set up any default configuration you did
  not set.
- call `visualMotionLocalizer(cfg)` to run the localizer.

The minimalist script would thus look like:

```matlab
clc;
clear;

%% Run MT+ localizer

cfg.design.localizer = 'MT';
initEnv();

cfg = checkParameters(cfg);

% Run
visualMotionLocalizer(cfg);
```

Type `help checkParameters` and see the [README in docs](./docs/README.md) to
get more information about the configuration options.

Run in debug mode (set `cfg.debug.do = true`) it does not care about subjID, run
n., Eye Tracker...

## Contributors ✨

Thanks goes to these wonderful people
([emoji key](https://allcontributors.org/docs/en/emoji-key)):

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

This project follows the
[all-contributors](https://github.com/all-contributors/all-contributors)
specification. Contributions of any kind welcome!
