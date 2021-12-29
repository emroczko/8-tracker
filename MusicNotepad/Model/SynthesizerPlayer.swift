//
//  SynthesizerDelegate.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 29/12/2021.
//

import Foundation
import AudioKitUI
import AudioKit

protocol SynthesizerPlayerDelegate {
    func removeFromMixer()
    func addToMixer()
    func getSequencerPosition()
}


class SynthesizerPlayer : KeyboardDelegate {
    
    weak var delegate: AudioManager?
    
    var synthesizers: [Synthesizer] = []
    
    func noteOn(note: MIDINoteNumber) {
        synthesizers[1].play(frequency: note.midiNoteToFrequency())
    }
    
    func noteOff(note: MIDINoteNumber) {
        synthesizers[1].stop(frequency: note.midiNoteToFrequency())
    }
    
    
    
}
