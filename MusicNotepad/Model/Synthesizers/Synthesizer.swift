//
//  Synthesizer.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 10/12/2021.
//

import Foundation
import SoundpipeAudioKit
import AudioKit
import AudioToolbox
import AudioKitUI

protocol Synthesizer {
    var amplitude: AUValue { get set }
    var frequency: AUValue { get set }
    var voices: Int { get set }
    var uniqueModification: AUValue { get set }
    
    func play(frequency: AUValue)
    func stop(frequency: AUValue)
    func stop()
    func fillSynthesizerWithOscillators()
    func changeAmplitude(value: AUValue)
    func changeUniqueModification(value: AUValue)
}

enum SynthesizerType : String {
    case PWMSynth = "PWM Synthesizer"
    case PhaseDisortedSynth = "Phase disorted synth"
    case WaveformMorphedSynth = "Waveform morphed synth"
}

