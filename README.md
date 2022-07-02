# MIDIfy
Spotify but for MIDIs
___
## Goals
This program aims to provide a usable listening experience on extremely low bandwidth and on heavly outdated hardware. Its also supposed to use as little external tools as possible for the task and to be as platform compatible as possible (except for Windows ;-b).
___
## Dependencies
This program only has three essential dependencies:

A somewhat recent version of bash, a native MIDI file player and CURL.
___
## Installation
To use this program, you need to install the `curl` package according to your OSes package managers instrucions. Under for example Debian that would be `sudo apt install curl`.

You will also need a MIDI file player. On default it tries to use `timidity` but you can change that in the configuration. Another good choice is (my own OPL3 emulator midi player)[https://github.com/iAmInActions/pioplemidi-cli] but any player should do the job.

If you have git installed, clone the program with the following command:
```
git clone http://github.com/iAmInActions/MIDIfy
```

In case your device does not support git or you simply want to not install git, download the repository as a zip file and extract it.
___
## Usage
To start the program, enter the directory and run `./midify.sh`

You can probably start using the program as is if you installed the dependencies and dont care about chaning anything. In case something isn't quite to your liking, simply edit the configuration part of `midify.sh` with an UTF-8 compliant text editor like vim or nano.

The controls are simple. A single `CTRL + C` skips a song, pressing it twice quits the program.
