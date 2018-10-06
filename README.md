# homebrew-makensis

[![BSD 2-Clause License](https://flat.badgen.net/badge/license/BSD%202-Clause/blue)](https://opensource.org/licenses/BSD-2-Clause)
[![Latest Release](https://flat.badgen.net/github/release/NSIS-Dev/homebrew-makensis)](https://github.com/NSIS-Dev/homebrew-makensis/releases)
[![Travis](https://flat.badgen.net/travis/NSIS-Dev/homebrew-makensis)](https://travis-ci.org/NSIS-Dev/homebrew-makensis)
[![David](https://flat.badgen.net/david/dev/NSIS-Dev/homebrew-makensis)](https://david-dm.org/NSIS-Dev/homebrew-makensis?type=dev)

Homebrew tap for Nullsoft Scriptable Install System (NSIS)

**Note:** The Homebrew core repository already supports NSIS. This tap repository is meant to install older versions or to build `makensis` with options

## Prerequisites

Make sure that [Homebrew](https://brew.sh/) is installed with `brew` in your `PATH` environmental variable

## Installation

Tap this repository in order to be able to install its formulae

```sh
$ brew tap nsis-dev/makensis
```

## Usage

You can now install any version of `makensis` between 2.34 and the latest using the command `brew install makensis@<version>`

```sh
$ brew install makensis@3.03
$ brew install makensis@2.51
```

To switch between versions, use the  command `brew link makensis@<version>`

```sh
$ brew link makensis@2.51
```

### Options

The support for build options was removed from the Homebrew core repository in [#87c4a30](https://github.com/Homebrew/homebrew-core/pull/31891/commits/87c4a30a90632a4a996633f1b25f85ec5efb25d7) on October 2nd, 2018.

#### `with-advanced-logging`

Enable [advanced logging](https://nsis.sourceforge.io/Special_Builds#Advanced_logging) of all installer actions

#### `with-large-strings`

Build makensis so installers can handle [large strings](https://nsis.sourceforge.io/Special_Builds#Large_strings) (>1024 characters)

#### `with-debug`

Build executables with debugging information.

**Note:** This is not meant for use in production!

## License

This work is licensed under the [BSD 2-Clause License](LICENSE)
