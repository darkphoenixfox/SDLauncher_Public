# SDLauncher
Development repo of the SDLauncher Sinden gun configuration assistant


## Installation:

Download the latest release.
Unzip to a folder of your liking (The program will run from this folder and use it as default to install additional software).

## Usage:
Run **SDlauncher.exe*

The Sinden software and drivers are installed and configured in the Sinden tab.

Playstation emulator is installed and configured in the Playstation tab. You can also configure your bezels here and run games.

SNES emulator is installed and configured in the SNES tab. You can also configure your bezels here and run games.

## Commandline and Launchbox usage:

SDLauncher accepts 2 parameters from commandline:
- 1st parameter for the system: ps1 mame snes -or- dc
- 2nd parameter for the game: full path to your iso or rom file or MAME rom name. Quotes are required if the path has any spaces:

Examples: 
*SDlauncher.exe ps1 "C:\games\Playstation 1\Time Crisis (U).iso"*

*SDlauncher.exe mame area51*



## Completed features
- Install and configure sinden software for 1 or 2 guns
- Install and Confgiure the following emulators:
    - MAME
    - SNES9x
    - Redream
    - Duckstation
- Configure bezels for SNES, PS1 and MAME
- Run games from commandline and launchers like Launchbox.

## To do features

## Prerequisites
- Windows 7/8/10
