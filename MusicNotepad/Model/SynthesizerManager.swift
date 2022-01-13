//
//  SynthesizerDelegate.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 29/12/2021.
//

import Foundation
import AudioKitUI
import AudioKit

protocol SynthManagerDelegate: AnyObject {
    func removeFromMixer(input: Node)
    func addToMixer(input: Node)
    func getSequencerPosition() -> Double
    func appendMidiMessage(note: MIDINoteData)
}


class SynthesizerManager : KeyboardDelegate {
    
    weak var delegate: SynthManagerDelegate?
    
    var isRecording : Bool = false
    var isCountIn : Bool = true
    var currentTrack : Int = 1
    var tempo : BPM = BPM(120)

    var synthesizers: [Synthesizer] = []
    var tmpMidiNotes : [MIDINoteNumber:Double] = [:]
    
    func initializeOscillators(){
        for _ in 0...7 {
            synthesizers.append(PWMSynthesizer())
        }
        
        for synth in synthesizers {
            if let current = synth as? PWMSynthesizer {
                for i in 0 ... synth.voices - 1 {
                    delegate?.addToMixer(input: current.oscillators[i])
                }
            }
        }
    }
    
    func setRecordingOptions(tempo: BPM, isRecording: Bool, trackToRecord: Int, isCountIn: Bool){
        self.tempo = tempo
        self.isRecording = isRecording
        self.currentTrack = trackToRecord
        self.isCountIn = isCountIn
    }
    
    func noteOn(note: MIDINoteNumber) {

        if(isRecording == true){
            print("note ON intside")
            let position = delegate?.getSequencerPosition()
            tmpMidiNotes[note] = isCountIn ? position! - 4 : position
            print(position!)
        }
        synthesizers[currentTrack - 1].play(frequency: note.midiNoteToFrequency())
    }
    
    func noteOff(note: MIDINoteNumber) {
        
        if(isRecording == true){
            let position = delegate?.getSequencerPosition()
            let endPosition = isCountIn ? position! - 4 : position
            let startPosition = Duration(beats: tmpMidiNotes[note]!, tempo: tempo)
            let duration = Duration(beats: endPosition! - tmpMidiNotes[note]!, tempo: tempo)
            
            delegate?.appendMidiMessage(note: MIDINoteData(noteNumber: MIDINoteNumber(note), velocity: MIDIVelocity(80), channel: 0, duration: duration, position: startPosition))
            
            tmpMidiNotes.removeValue(forKey: note)
        }
        synthesizers[currentTrack - 1].stop(frequency: note.midiNoteToFrequency())
    }
    
    
    func changeSynthesizer(trackNumber: Int, newSynthesizer: SynthesizerType){
        
        print("in func")
        if let current = synthesizers[trackNumber - 1] as? PWMSynthesizer {
            for i in 0 ... current.voices - 1 {
                delegate?.removeFromMixer(input: current.oscillators[i])
            }
        }
        if let current = synthesizers[trackNumber - 1] as? WaveMorphedSynthesizer {
            for i in 0 ... current.voices - 1 {
                delegate?.removeFromMixer(input: current.oscillators[i])
            }
        }
        if let current = synthesizers[trackNumber - 1] as? PhaseDisortedSynthesizer {
            for i in 0 ... current.voices - 1 {
                delegate?.removeFromMixer(input: current.oscillators[i])
            }
        }

        switch(newSynthesizer){
        case .PWMSynth:
            synthesizers[trackNumber - 1] = PWMSynthesizer()
            if let synth = synthesizers[trackNumber - 1] as? PWMSynthesizer {
                for i in 0 ... synth.voices - 1 {
                    delegate?.addToMixer(input: synth.oscillators[i])
                }
                print("current1 synth: \(newSynthesizer.rawValue)")
            }
        case .WaveformMorphedSynth:
            synthesizers[trackNumber - 1] = WaveMorphedSynthesizer()
            if let synth = synthesizers[trackNumber - 1] as? WaveMorphedSynthesizer {
                for i in 0 ... synth.voices - 1 {
                    delegate?.addToMixer(input: synth.oscillators[i])
                }
                print("current2 synth: \(newSynthesizer.rawValue)")
            }
        case.PhaseDisortedSynth:
            synthesizers[trackNumber - 1] = PhaseDisortedSynthesizer()
            if let synth = synthesizers[trackNumber - 1] as? PhaseDisortedSynthesizer {
                for i in 0 ... synth.voices - 1 {
                    delegate?.addToMixer(input: synth.oscillators[i])
                }
                print("current3 synth: \(newSynthesizer.rawValue)")
            }
        }
    }
    
    
    
}
