# MusicNotepad
> Music application allowing to record sound on 8 tracks. 

## Table of contents
* [General info](#general-info)
* [Screenshots](#screenshots)
* [Technologies](#technologies)
* [Future](#future)

## General info
This is a MusicNotepad - project created as a subject of my Engineer's thesis. 
It allows for recording, playing playback, playing MIDI keyboard and much more.
You have 8 tracks to record - you can choose track as an audio track or a MIDI track. This choice defines how sound will be recorded. Audio track means recording with microphone, MIDI track means recording with keyboard. 
It has a built in metronome which can be muted.
The most important feature is an audio converter to MIDI. After you record an audio track you can convert it into MIDI regions, which can be played with one of 3 built in synthesizers. 
You can change modulation of each synthesizer, which changes its sound. 

## Screenshots
![Launch screenshot](Screenshots/screenshot1.PNG)
![Main tracks view screenshot](Screenshots/screenshot2.PNG)

## Technologies
* Swift - 5.0
* AudioKit - 5.3
* SoundPipeAudioKit - 5.3
* AudioKitUI - 5.3

## Features
* Recording sounds on 8 track 
* Playing all tracks simultaneously
* Converting recorded audio to MIDI
* MIDI keyboard allowing to record
* MIDI regions view with editing options

## Status
Project is: _in progress_

Copyright. All rights belongs to me :) 
