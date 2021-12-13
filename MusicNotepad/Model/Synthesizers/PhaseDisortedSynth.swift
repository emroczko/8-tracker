//
//  PhaseDisortedSynth.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 13/12/2021.
//

import Foundation
import AudioKit
import AudioToolbox
import AudioKitEX
import SoundpipeAudioKit


class PhaseDisortedSynthesizer : Synthesizer, Node {
    var connections: [Node] { [] }
    var avAudioNode = instantiate(generator: "pdho")
    
    var amplitude: AUValue = 1
    var frequency: AUValue = 440
    var uniqueModification: Float = 0 {
        didSet {
            changeUniqueModification(value: uniqueModification)
        }
    }
    var oscillators: [PhaseDistortionOscillator] = []
    
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
            oscillators.append(PhaseDistortionOscillator())
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
            oscillator.phaseDistortion = value
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
