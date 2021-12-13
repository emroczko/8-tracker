//
//  WaveMorphedSynthesizer.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 13/12/2021.
//

import Foundation
import AudioKit
import AudioToolbox
import AudioKitEX
import SoundpipeAudioKit


class WaveMorphedSynthesizer : Synthesizer, Node {
    var connections: [Node] { [] }
    var avAudioNode = instantiate(generator: "morf")
    
    var amplitude: AUValue = 1
    var frequency: AUValue = 440
    var uniqueModification: Float = 1.5 {
        didSet {
            changeUniqueModification(value: uniqueModification)
        }
    }
    var oscillators: [MorphingOscillator] = []
    
    var voices: Int = 3 {
        didSet{
            clearOscillators()
            fillSynthesizerWithOscillators()
        }
    }
    
    init(){
        setupParameters()
        changeUniqueModification(value: uniqueModification)
        fillSynthesizerWithOscillators()
    }
    
    
    func fillSynthesizerWithOscillators(){
        clearOscillators()
        for _ in 1 ... voices {
            oscillators.append(MorphingOscillator())
        }
    }
    
    func clearOscillators(){
        oscillators.removeAll()
    }
    
    func changeAmplitude(value: AUValue) {
        for oscillator in oscillators {
            oscillator.amplitude = value
        }
    }
    
    func changeUniqueModification(value: AUValue) {
        for oscillator in oscillators {
            oscillator.index = value
        }
    }
    
    
    func play(frequency: AUValue) {
        print("playing")
//        for oscillator in oscillators {
//            if (oscillator.isStarted == false) {
//                oscillator.frequency = frequency
//                oscillator.start()
//            }
//        }
        oscillators[0].frequency = frequency
        oscillators[0].start()
    }
    
    func stop(frequency: AUValue) {
        for oscillator in oscillators {
            if (oscillator.frequency == frequency && oscillator.isStarted) {
                oscillator.stop()
            }
        }
    }
    
    func stop(){
        for oscillator in oscillators {
            oscillator.stop()
        }
    }

}
