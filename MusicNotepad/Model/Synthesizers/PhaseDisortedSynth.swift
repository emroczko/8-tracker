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
    
    var amplitude: AUValue = 0.8 {
        didSet {
            changeAmplitude(value: amplitude)
        }
    }
    
    var uniqueModification: Float = 0 {
        didSet {
            changeUniqueModification(value: uniqueModification)
        }
    }
    var oscillators: [PhaseDistortionOscillator] = []
    
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
        initOscillators()
    }
    
    func initOscillators(){
        for oscillator in oscillators {
            oscillator.$amplitude.ramp(to: 0.8, duration: 0.02)
        }
    }
    
    func fillSynthesizerWithOscillators(){
        clearOscillators()
        for _ in 1 ... voices {
            oscillators.append(PhaseDistortionOscillator())
            activeVoices.append(false)
        }
    }
    
    func clearOscillators(){
        oscillators.removeAll()
    }
    
    func changeAmplitude(value: AUValue) {
        for oscillator in oscillators {
            oscillator.$amplitude.ramp(to: value, duration: 0.02)
        }
    }
    
    func changeUniqueModification(value: AUValue) {
        for oscillator in oscillators {
            oscillator.$phaseDistortion.ramp(to: value, duration: 0.02)
        }
    }
    
    func findFreeVoice() -> Int {
        for i in 0 ... oscillators.count - 1 {
            if(activeVoices[i] == false){
                    return i
            }
        }
        return -1
    }
    
    func play(frequency: AUValue) {
        let freeVoiceNumber = findFreeVoice()
        if(freeVoiceNumber == -1){
            return
        }
        print("playing oscillator \(freeVoiceNumber + 1): frequency: \(oscillators[freeVoiceNumber].frequency)")
        activeVoices[freeVoiceNumber] = true
        oscillators[freeVoiceNumber].start()
        oscillators[freeVoiceNumber].$frequency.ramp(to: frequency, duration: 0.02)
        oscillators[freeVoiceNumber].$amplitude.ramp(to: amplitude, duration: 0.02)
    }
    
    func stop(frequency: AUValue) {
        for i in 0 ... oscillators.count - 1 {
            if (oscillators[i].frequency == frequency && activeVoices[i] == true) {
                oscillators[i].amplitude = 0
                activeVoices[i] = false

            }
        }
    }
    
    func stop(){
        for oscillator in oscillators {
            oscillator.stop()
        }
    }
}
