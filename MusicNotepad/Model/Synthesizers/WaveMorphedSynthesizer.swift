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
    
    var amplitude: AUValue = 0.8 {
        didSet {
            changeAmplitude(value: amplitude)
        }
    }
    var frequency: AUValue = 440
    var uniqueModification: Float = 1.5 {
        didSet {
            changeUniqueModification(value: uniqueModification)
        }
    }
    var oscillators: [MorphingOscillator] = []
    
    var voices: Int = 4 {
        didSet{
            clearOscillators()
            fillSynthesizerWithOscillators()
        }
    }
    
    var activeVoices: [Bool] = []
    
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
    
    func findFreeVoice() -> Int {
        for i in 0 ... oscillators.count - 1 {
            if(oscillators[i].isStarted == false){
                    return i
            }
        }
        return -1
    }
    
    
    func play(frequency: AUValue) {
        print("playing")
        let freeVoiceNumber = findFreeVoice()
        if(freeVoiceNumber == -1){
            return
        }
        oscillators[freeVoiceNumber].frequency = frequency
        oscillators[freeVoiceNumber].start()
    }
    
    func stop(frequency: AUValue) {
        for i in 0 ... oscillators.count - 1 {
            if (oscillators[i].frequency == frequency && oscillators[i].isStarted) {
                oscillators[i].stop()
                
            }
        }
    }
    
    func stop(){
        for oscillator in oscillators {
            oscillator.stop()
        }
    }

}
