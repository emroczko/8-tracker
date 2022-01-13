//
//  Metronome.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 14/11/2021.
//

import Foundation
import AudioKit
import AudioKitEX
import AVKit
import SwiftUI
import AudioKitUI
import SoundpipeAudioKit

struct SequencerData {
    var isPlaying = false
    var tempo: BPM = 120
    var sequenceLength: Int = 33
    var beatNoteVelocity = 100.0
    var currentBeat: Float = 0
    var metronomeColor: Color = Color.black.opacity(0.75)
    var isMetronomePlaying = true
    var isCountIn = true
    var isLooped = false
    var isRecording = false
    var soloTrack: Int = 0
    var trackToRecord: Int = 0
    var currentTrack: Int = 0
}

struct TrackData {
    var isMidiEnabled : Bool = false
    var isAudioEnabled : Bool = true
    var isMuted : Bool = false
    var isAudioRecorded : Bool = false
    var isMidiRecorded: Bool = false
    var trackType : TrackType = .NONE
    var audioVolume : AUValue = 40
    var midiNotes: [MIDINoteData] = []
}

class AudioManager: ObservableObject, SynthManagerDelegate {

    let tracksCount : Int = 8
    let engine = AudioEngine()
    var callbackVisualMetronome = MIDICallbackInstrument()
    var callbackAudioTracks = MIDICallbackInstrument()
    var callbackAudioRecording = MIDICallbackInstrument()
    var callbackMidiRecording = MIDICallbackInstrument()
    let mixer = Mixer()
    let metronomeMixer = Mixer()
    var sequencer = AppleSequencer()
    var players = [URL:AudioPlayer]()
    var audioRecorder: AudioRecorderManager = AudioRecorderManager()
    var applicationState = ApplicationState.shared
    var sequencerPosition: Float = 0.0
    var callbackSynths: [MIDICallbackInstrument] = []
    var isMIDI: Bool = false

    @Published var synthesizerManager: SynthesizerManager = SynthesizerManager()
    @Published var tracksData: [TrackData] = [TrackData]()
    @Published var data = SequencerData() {
        didSet {
            updateSequences()
            data.isPlaying ? startSequencer() : sequencer.stop()
            if(data.isRecording){
                sequencer.disableLooping()
            }
            else{
                sequencer.enableLooping()
            }
            sequencer.setTempo(data.tempo)
            synthesizerManager.currentTrack = data.currentTrack
        }
    }

    func updateSequences() {
        
        let length = data.isCountIn && data.isRecording ? data.sequenceLength + 4 : data.sequenceLength
        var track = sequencer.tracks.first!

        track.clear()
        track.setLength(Duration(beats: Double(length), tempo: data.tempo))

        let vel = MIDIVelocity(Int(data.beatNoteVelocity))
        if(data.isMetronomePlaying){
            for beat in 1 ..< length {
                track.add(midiNoteData: MIDINoteData(noteNumber: MIDINoteNumber((beat ) % 4 == 1 ? 67 : 60), velocity: 127, channel: 1, duration: Duration(beats: 0.4, tempo: data.tempo), position: Duration(beats: Double(beat), tempo: data.tempo)))
            }
        }
        else{
            if(data.isCountIn && data.isRecording){
                for i in 1 ... 4 {
                    track.add(midiNoteData: MIDINoteData(noteNumber: MIDINoteNumber(i == 0 ? 6 : 10), velocity: 127, channel: 1, duration: Duration(beats: 0.4, tempo: data.tempo), position: Duration(beats: Double(i), tempo: data.tempo)))
                }
            }
        }
        
        sequencer.tracks[0].add(midiNoteData: MIDINoteData(noteNumber: MIDINoteNumber(60), velocity: vel, channel: 1, duration: Duration(beats: 1, tempo: data.tempo), position: Duration(beats: Double(2), tempo: data.tempo)))


        track = sequencer.tracks[1]
        track.clear()
        track.setLength(Duration(beats: Double(length), tempo: data.tempo))
        for beat in 1 ..< length{
            track.add(midiNoteData: MIDINoteData(noteNumber: MIDINoteNumber(beat), velocity: vel, channel: 1, duration: Duration(beats: 0.4, tempo: data.tempo), position: Duration(beats: Double(beat), tempo: data.tempo)))
        }

        let position = data.isCountIn && data.isRecording ? Double(5) : Double(1)

        for i in 2 ... 4 {
            track = sequencer.tracks[i]
            track.clear()
            track.setLength(Duration(beats: Double(length), tempo: data.tempo))
            track.add(midiNoteData: MIDINoteData(noteNumber: MIDINoteNumber(0), velocity: vel, channel: 1, duration: Duration(beats: 32, tempo: data.tempo), position: Duration(beats: position, tempo: data.tempo)))
        }

        for i in 1...tracksCount {
            if((tracksData[i - 1].isMidiEnabled == true || tracksData[i - 1].isMidiRecorded == true) && i != data.trackToRecord){
                track = sequencer.tracks[i + 4]
                track.clear()
                track.setLength(Duration(beats: Double(length), tempo: data.tempo))

                for note in tracksData[i - 1].midiNotes {
                    let position = data.isCountIn && data.isRecording ? Double(note.position.beats + 5) : Double(note.position.beats + 1)
                    var tempNote = note
                    
                    tempNote.position = Duration(beats: position, tempo: data.tempo)
                    track.add(midiNoteData: tempNote)
                    //track.add(midiNoteData: MIDINoteData(noteNumber: note.noteNumber, velocity: note.velocity, channel: 1, duration: note.duration, position: Duration(beats: position,  tempo: data.tempo)))
                    track.add(midiNoteData: MIDINoteData(noteNumber: MIDINoteNumber(note.noteNumber), velocity: 127, channel: 1, duration: note.duration, position: Duration(beats: position, tempo: data.tempo)))
                }

            }

        }
    }
    
    func addMidiToTrack(trackNumber: Int, notes: [MIDINoteData]){
        
        if(tracksData[trackNumber - 1].midiNotes.isEmpty == false){
            tracksData[trackNumber - 1].midiNotes = []
        }
        tracksData[trackNumber - 1].midiNotes = notes

    }
    
    init() {
    
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        try! AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        AVAudioSession.sharedInstance().requestRecordPermission{_ in }
    
        let metronomeTrack = sequencer.newTrack()
        
        let sampler = MIDISampler()
        let metronomeSoundUrl = Bundle.main.url(forResource: "regularMetronome", withExtension: "wav")
        
        try! sampler.loadAudioFile(AVAudioFile(forReading: metronomeSoundUrl!))
        metronomeTrack?.setMIDIOutput(sampler.midiIn)
        
        let metronome = Fader(sampler)
        metronome.gain = 60
    
        for _ in 1 ... tracksCount {
            tracksData.append(TrackData())
        }
        
        

        callbackVisualMetronome = MIDICallbackInstrument{ [self]
                                                         status, beat, _ in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            let length = self.data.isCountIn && self.data.isRecording ? self.data.sequenceLength + 3 : self.data.sequenceLength - 1

            if (self.data.isLooped == false && beat == length && midiStatus == .noteOff) {
                print("koniec")
                self.stopRecording()
                self.data.isPlaying = false
                self.applicationState.isPlaying = false
                self.applicationState.isRecording = false
                self.stopTracks()
                self.sequencer.rewind()
            }

            DispatchQueue.main.async {
                if(length > self.data.sequenceLength){
                    if(beat < 4){
                        self.data.currentBeat = 0
                    }else{
                        self.data.currentBeat = Float(beat - 4)
                    }
                }
                else{
                    self.data.currentBeat = Float(beat) + 1
                }
            if(midiStatus != .noteOn){ return }
                

            print(beat)

                if((beat + 1) % 4 == 1){
                    self.data.metronomeColor = Color.blue.opacity(0.75)
                }
                else{
                    self.data.metronomeColor = Color.pink.opacity(0.75)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.data.metronomeColor = Color.black.opacity(0.75)
                }
            }
        }
    
        
        let visualMetronomeTrack = sequencer.newTrack()
        visualMetronomeTrack?.setMIDIOutput(callbackVisualMetronome.midiIn)

        callbackAudioTracks = MIDICallbackInstrument{ [self]
            status, beat, _ in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            if(midiStatus != .noteOn){ return }
            
            DispatchQueue.main.async {
                self.playTracks()
            }
        }

        callbackAudioRecording = MIDICallbackInstrument{ [self]
            status, beat, _ in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            
            if(midiStatus != .noteOn){ return }
            
            if(self.data.isRecording && self.tracksData[self.data.trackToRecord - 1].trackType == .AUDIO){
                DispatchQueue.main.async {
                    self.record()
                }
            }
        }

        callbackMidiRecording = MIDICallbackInstrument{ [self]
            status, beat, _ in
            print("callback rec: \(beat)")
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            if(midiStatus != .noteOn){ return }
            
            
            let trackToRecord = self.data.trackToRecord - 1

            if(self.data.isRecording && self.tracksData[trackToRecord].trackType == .MIDI){
                self.synthesizerManager.setRecordingOptions(tempo: self.data.tempo, isRecording: true,
                                                           trackToRecord: trackToRecord, isCountIn: self.data.isCountIn)
                self.tracksData[trackToRecord].isMidiRecorded = true
            }
        }

        let audioTracks = sequencer.newTrack()
        audioTracks?.setMIDIOutput(callbackAudioTracks.midiIn)
        
        let audioRecording = sequencer.newTrack()
        audioRecording?.setMIDIOutput(callbackAudioRecording.midiIn)
        
        let midiRecording = sequencer.newTrack()
        midiRecording?.setMIDIOutput(callbackMidiRecording.midiIn)

        mixer.addInput(metronome)
        mixer.addInput(callbackVisualMetronome)
        mixer.addInput(callbackVisualMetronome)
        mixer.addInput(callbackAudioTracks)
        mixer.addInput(callbackAudioRecording)
        mixer.addInput(callbackMidiRecording)
        
        for i in 0...7 {

            callbackSynths.append(MIDICallbackInstrument { [self]
                status, noteNumber, _ in
                guard let midiStatus = MIDIStatusType.from(byte: status) else {
                    return
                }
                print("playing callback \(i+1)")
                print("status: \(midiStatus)")

                if(noteNumber == 127){
                    self.isMIDI = false
                    self.synthesizerManager.synthesizers[i].stop()
                    return
                }

                if(midiStatus == .noteOn){
                    self.synthesizerManager.synthesizers[i].play(frequency: noteNumber.midiNoteToFrequency())
                }
                else{
                    self.synthesizerManager.synthesizers[i].stop(frequency: noteNumber.midiNoteToFrequency())
                }
            })
            
            let synthTrack = sequencer.newTrack()
            synthTrack?.setMIDIOutput(callbackSynths[i].midiIn)

        }

        for callback in callbackSynths {
             mixer.addInput(callback)
        }
        
        checkIfAudioExists()
        sequencer.enableLooping()
        updateSequences()
        
        synthesizerManager.delegate = self
        synthesizerManager.initializeOscillators()
    
        engine.output = mixer
        
    }
    
    func checkIfAudioExists(){
        for i in 1 ... tracksCount {
            if(FilesManager.checkIfFileExists(trackNumber: i)){
                tracksData[i - 1].isAudioRecorded = true
            }
        }
    }
    
    func removeFromMixer(input: Node) {
        mixer.removeInput(input)
    }
    
    func addToMixer(input: Node) {
        print("adding input")
        mixer.addInput(input)
    }
    
    func getSequencerPosition() -> Double {
        return sequencer.currentPosition.beats
    }
    
    func appendMidiMessage(note: MIDINoteData) {
        tracksData[data.trackToRecord - 1].midiNotes.append(note)
    }

    func playTrack(trackNumber: Int){

        let fileURL = FilesManager.getFileURL(trackNumber: trackNumber)
        
        guard FilesManager.checkIfFileExists(fileURL: fileURL)
        else { return }
        
        let file = try! AVAudioFile(forReading: fileURL)
        
        if let player = players[fileURL] {
            mixer.addInput(player)
            player.volume = tracksData[trackNumber - 1].audioVolume
            player.play()
            
                
        } else {
            let player = AudioPlayer(file: file)!
            mixer.addInput(player)
            players[fileURL] = player
            player.volume = tracksData[trackNumber - 1].audioVolume
            player.play()
            
        }
    }
    
    func deleteTrackFromPlayers(trackNumber: Int){
        let fileURL = FilesManager.getFileURL(trackNumber: trackNumber)
        
        guard FilesManager.checkIfFileExists(fileURL: fileURL)
        else { return }
        
        players[fileURL] = nil
        
    }
    
    func stopRecording(){
        print("stop outside")
        if(data.isRecording){
            print("stop inside")
            data.currentBeat = 0
            synthesizerManager.isRecording = false
            audioRecorder.stopRecording()
            sequencer.stop()
            data.isRecording = false
        }
    }
    
    func record(){
        audioRecorder.startRecording(trackNumber: self.data.trackToRecord)
        tracksData[data.trackToRecord - 1].isAudioRecorded = true
    }
    
    func playTracks(){
        if(data.soloTrack == 0){
            for i in 1 ... tracksCount {
                if(tracksData[i - 1].isMuted == false && i != data.trackToRecord && tracksData[i - 1].isAudioEnabled == true){
                    DispatchQueue.main.async {
                        self.playTrack(trackNumber: i)
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                self.playTrack(trackNumber: self.data.soloTrack)
            }
        }
        
    }
    func startSequencer(){
        if(!sequencer.isPlaying){
            sequencer.preroll()
            sequencer.play()
            
        }
    }
    
    func clearTrack(trackNumber: Int){
        deleteTrackFromPlayers(trackNumber: trackNumber)
        FilesManager.deleteRecording(trackNumber: trackNumber)
        tracksData[trackNumber - 1].isAudioRecorded = false
        tracksData[trackNumber - 1].isMidiEnabled = false
        tracksData[trackNumber - 1].midiNotes.removeAll()
        tracksData[trackNumber - 1].trackType = .AUDIO
        tracksData[trackNumber - 1].isMidiRecorded = false
        
        //sequencer.tracks[trackNumber + 3].clear()
    }
    
    func stopTracks(){
        DispatchQueue.main.async {
            self.data.metronomeColor = Color.black.opacity(0.75)
            for player in self.players {
                player.value.stop()
            }
            self.data.currentBeat = 0
        }
    }

    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        stopTracks()
        sequencer.stop()
        engine.stop()
    }
}
