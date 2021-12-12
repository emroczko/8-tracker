//
//  Metronome.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 14/11/2021.
//

import Foundation
import AudioKit
import AudioKitEX
import STKAudioKit
import AVKit
import SwiftUI
import SoundpipeAudioKit

struct MetronomeData {
    var isPlaying = false
    var tempo: BPM = 120
    var sequenceLength: Int = 32
    var downbeatNoteNumber = MIDINoteNumber(6)
    var beatNoteNumber = MIDINoteNumber(10)
    var beatNoteVelocity = 100.0
    var currentBeat: Float = 0
    var color: Color = Color.black.opacity(0.75)
    var isMetronomePlaying = true
    var isCountIn = true
    var isLooped = false
    var isRecording = false
    var soloTrack: Int = 0
    var trackToRecord: Int = 0
    
    var tracksMuted: [Int:Bool] = [1: false,
                       2: false,
                       3: false,
                       4: false,
                       5: false,
                       6: false,
                       7: false,
                       8: false,
    ]
}

struct TrackData {
    var isMidiEnabled : Bool = false
    var isAudioEnabled : Bool = true
    var isMuted : Bool = false
    var isAudioRecorded : Bool = false
}

class AudioManager: ObservableObject {

    let tracksCount : Int = 8
    let engine = AudioEngine()
    let shaker = Shaker()
    let rhodes = RhodesPianoKey()
    var callbackVisualMetronome = CallbackInstrument()
    var callbackAudioTracks = CallbackInstrument()
    var callbackRecording = CallbackInstrument()
    let reverb: Reverb
    let mixer = Mixer()
    var sequencer = Sequencer()
    var players = [URL:AudioPlayer]()
    var audioRecorder: CustomAudioRecorder = CustomAudioRecorder()
    var applicationState = ApplicationState.shared
    var sequencerPosition: Float = 0.0
    let midi = MIDI()
    var callbackSynth = CallbackInstrument()
    var callbackSynths: [CallbackInstrument] = []
    var isMIDI: Bool = false
    var midiNotes: [Int:[MIDINoteData]] = [1:[],
                                           2:[],
                                           3:[],
                                           4:[],
                                           5:[],
                                           6:[],
                                           7:[],
                                           8:[]]
    @Published var synthesizers: [Synthesizer] = []
    @Published var tracksData: [TrackData] = [TrackData]()
    @Published var data = MetronomeData() {
        didSet {
            updateSequences()
            data.isPlaying ? playSeq() : stopSeq()
            if(data.isRecording){
                sequencer.loopEnabled = false
            }
            else{
                sequencer.loopEnabled = data.isLooped
            }
            
            sequencer.tempo = data.tempo
        }
    }

    func updateSequences() {
        let length = data.isCountIn && data.isRecording ? data.sequenceLength + 4 : data.sequenceLength
        var track = sequencer.tracks.first!

        track.length = Double(length)
        track.clear()
        let vel = MIDIVelocity(Int(data.beatNoteVelocity))
        if(data.isMetronomePlaying){
            for beat in 0 ..< length {
                if((beat + 1) % 4 == 1){
                    track.sequence.add(noteNumber: data.downbeatNoteNumber, position: Double(beat), duration: 0.4)
                }
                else{
                    track.sequence.add(noteNumber: data.beatNoteNumber, velocity: vel, position: Double(beat), duration: 0.1)
                }
            }
        }
        else{
            if(data.isCountIn && data.isRecording){
                track.sequence.add(noteNumber: data.downbeatNoteNumber, position: Double(0), duration: 0.4)
                track.sequence.add(noteNumber: data.beatNoteNumber, position: Double(1), duration: 0.1)
                track.sequence.add(noteNumber: data.beatNoteNumber, position: Double(2), duration: 0.1)
                track.sequence.add(noteNumber: data.beatNoteNumber, position: Double(3), duration: 0.1)
            }
        }
        
        track = sequencer.tracks[1]
        track.length = Double(length)
        track.clear()
        
        for beat in 0 ..< length{
            track.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
        }
        
        var position = data.isCountIn && data.isRecording ? Double(4) : Double(0)
        
        track = sequencer.tracks[2]
        track.length = Double(length)
        track.clear()
        track.sequence.add(noteNumber: MIDINoteNumber(0), position: position, duration: 20)
        
        track = sequencer.tracks[3]
        track.length = Double(length)
        track.clear()
        track.sequence.add(noteNumber: MIDINoteNumber(0), position: position, duration: 20)
        
        
        
        for i in 1...tracksCount {
            if(tracksData[i - 1].isMidiEnabled == true){
                track = sequencer.tracks[i + 3]
                track.length = Double(length)
                track.clear()

                for note in midiNotes[i]! {
                    let position = data.isCountIn && data.isRecording ? Double(note.position.beats + 4) : Double(note.position.beats)
                    track.sequence.add(noteNumber: note.noteNumber, position: position, duration: Double(note.duration.beats))
                }

                if(midiNotes[i]?.count ?? 0 > 0){
                    position = data.isCountIn && data.isRecording ? Double((midiNotes[i]!.last?.position.beats)! + 4) : Double((midiNotes[i]!.last?.position.beats)!)
                    track.sequence.add(noteNumber: 127, position: position, duration: Double((midiNotes[i]!.last?.duration.beats)!))
                }
            }
            
        }
    }
    
    func addMidiToTrack(trackNumber: Int, notes: [MIDINoteData]){
        
        if(midiNotes[trackNumber]?.isEmpty == false){
            midiNotes[trackNumber] = []
        }
        midiNotes[trackNumber] = notes
    }
    
    init() {
    
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        
        try! AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        
        let _ = sequencer.addTrack(for: shaker)
        
        AVAudioSession.sharedInstance().requestRecordPermission{_ in }

        let fader = Fader(shaker)
        fader.gain = 30.0

        //        let delay = Delay(fader)
        //        delay.time = AUValue(1.5 / playRate)
        //        delay.dryWetMix = 0.7
        //        delay.feedback = 0.2
        reverb = Reverb(fader)
        
        
        for _ in 1 ... tracksCount {
            tracksData.append(TrackData())
        }
        
        checkIfAudioExists()

        callbackVisualMetronome = CallbackInstrument(midiCallback: { (status, beat, _) in
            
            let midiStatus = MIDIStatus(byte: status)
            let length = self.data.isCountIn && self.data.isRecording ? self.data.sequenceLength + 3 : self.data.sequenceLength - 1
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
            
            if (self.data.isLooped == false && beat == length && midiStatus?.type == .noteOff) {
                print("koniec")
                self.stopRecording()
                self.data.isPlaying = false
                self.applicationState.isPlaying = false
                self.applicationState.isRecording = false
                self.stopTracks()
                self.sequencer.rewind()
            }
            
            
            
            if (midiStatus?.type != .noteOn){ return }
            
            
            
            print(beat)
            if((beat + 1) % 4 == 1){
                self.data.color = Color.blue.opacity(0.75)
            }
            else{
                self.data.color = Color.pink.opacity(0.75)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.data.color = Color.black.opacity(0.75)
            }
            
        })
        
        callbackAudioTracks = CallbackInstrument(midiCallback: { (status, beat, _) in
            if let midiStatus = MIDIStatus(byte: status), midiStatus.type != .noteOn { return }
        
            DispatchQueue.main.async {
                print("play tracks")
                self.playTracks()
            }
        })
        
        
        
        
        callbackRecording = CallbackInstrument(midiCallback: { (status, beat, _) in
            print("callback rec: \(beat)")
            if let midiStatus = MIDIStatus(byte: status), midiStatus.type != .noteOn { return }
            
            if(self.data.isRecording){
                print("rec: \(beat)")
                //DispatchQueue.main.async {
                    self.record()
                //}
            }
        })

        let _ = sequencer.addTrack(for: callbackVisualMetronome)
        let _ = sequencer.addTrack(for: callbackAudioTracks)
        let _ = sequencer.addTrack(for: callbackRecording)
        
        for i in 0...7 {
            synthesizers.append(PWMSynthesizer())
            
            callbackSynths.append(CallbackInstrument(midiCallback: { status, noteNumber, velocity in
                let midiStatus = MIDIStatus(byte: status)
                print("playing callback \(i+1)")
                
                if(noteNumber == 127){
                    self.isMIDI = false
                    //self.synth.stop()
                    self.synthesizers[i].stop()
                    return
                }
                
                if(midiStatus?.type == .noteOn){
                    print("playing \(noteNumber.midiNoteToFrequency())")
                    //self.synth.play(frequency: noteNumber.midiNoteToFrequency())
                    //self.synth.frequency = noteNumber.midiNoteToFrequency()
                    self.synthesizers[i].play(frequency: noteNumber.midiNoteToFrequency())
                }
                else{
                    print("stoppin \(noteNumber.midiNoteToFrequency())")
                    self.synthesizers[i].stop(frequency: noteNumber.midiNoteToFrequency())
                    
                }
            }))
            
            let _ = sequencer.addTrack(for: callbackSynths[i])
        }
        
        sequencer.loopEnabled = data.isLooped
        updateSequences()

        
//        let fader2 = Fader(rhodes)
//        fader2.gain = 30.0

//        let fader2 = Fader(synth.oscillators[0])
//        fader2.gain = 10.0
        
        mixer.addInput(fader)
        mixer.addInput(callbackVisualMetronome)
        mixer.addInput(callbackAudioTracks)
        mixer.addInput(callbackRecording)
   //     mixer.addInput(defaultOsc)

        //mixer.addInput(fader2)
        mixer.addInput(callbackSynth)
        
        
        for synth in synthesizers {
            if let current = synth as? PWMSynthesizer {
                mixer.addInput(current.oscillators[0])
            }
        }
        
        for callback in callbackSynths {
            mixer.addInput(callback)
        }
        
        

        engine.output = mixer

    }
    
    func checkIfAudioExists(){
        for i in 1 ... tracksCount {
            if(FilesManager.checkIfFileExists(trackNumber: i)){
                tracksData[i - 1].isAudioRecorded = true
            }
        }
    }
    
    func enableMidi(){
        print("enableMidi")
    }
    
    func playSeq(){
        sequencer.play()

    }
    
    func stopSeq(){
        sequencer.stop()
    }
    
    func playTrack(trackNumber: Int){

        let fileURL = FilesManager.getFileURL(trackNumber: trackNumber)
        
        guard FilesManager.checkIfFileExists(fileURL: fileURL)
        else { return }
        
        let file = try! AVAudioFile(forReading: fileURL)
        
        if let player = players[fileURL] {
            mixer.addInput(player)
            player.volume = 80
            player.play()
            
                
        } else {
            let player = AudioPlayer(file: file)!
            mixer.addInput(player)
            players[fileURL] = player
            player.volume = 80
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
            self.data.currentBeat = 0
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
            for (trackNumber, value) in data.tracksMuted {
                if(value == false && trackNumber != data.trackToRecord && tracksData[trackNumber - 1].isAudioEnabled == true){
                    DispatchQueue.main.async {
                        self.playTrack(trackNumber: trackNumber)
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
    
    func clearTrack(trackNumber: Int){
        deleteTrackFromPlayers(trackNumber: trackNumber)
        FilesManager.deleteRecording(trackNumber: trackNumber)
        tracksData[trackNumber - 1].isAudioRecorded = false
        tracksData[trackNumber - 1].isMidiEnabled = false
        midiNotes[trackNumber]?.removeAll()
        //sequencer.tracks[trackNumber + 3].clear()
    }
    
    func stopTracks(){
        data.color = Color.black.opacity(0.75)
        for player in players {
            player.value.stop()
        }
        self.data.currentBeat = 0
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
