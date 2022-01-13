//
//  SwiftUIView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 26/11/2021.
//

import SwiftUI

struct InstrumentSettings: View {
    @EnvironmentObject var player : AudioManager
    @State var selectedSynth : SynthesizerType = SynthesizerType.PWMSynth
    var trackNumber: Int
    
    var body: some View {
        VStack {
            Picker(selection: $selectedSynth, label: Text("Picker"), content: {
                
                Text(SynthesizerType.PWMSynth.rawValue).tag(SynthesizerType.PWMSynth)
                    .foregroundColor(.blue)
                Text(SynthesizerType.WaveformMorphedSynth.rawValue).tag(SynthesizerType.WaveformMorphedSynth)
                    .foregroundColor(.blue)
                Text(SynthesizerType.PhaseDisortedSynth.rawValue).tag(SynthesizerType.PhaseDisortedSynth)
                    .foregroundColor(.blue)
                
            })
            .pickerStyle(.wheel)
            .onChange(of: selectedSynth, perform: { newSynthesizer in
                print("new value: \(newSynthesizer.rawValue)")
                player.synthesizerManager.changeSynthesizer(trackNumber: trackNumber, newSynthesizer: newSynthesizer)
            })
            
            CustomSlider(value: $player.synthesizerManager.synthesizers[trackNumber - 1].amplitude, label: "Volume", range: 0 ... 1)
                .frame(height: 15)
                .padding(.trailing)
                .padding(.leading)
                .padding(.bottom)
            
            switch(selectedSynth){
            case .PWMSynth:
                CustomSlider(value: $player.synthesizerManager.synthesizers[trackNumber - 1].uniqueModification, label: "PWM", range: 0.1 ... 0.99)
                    .frame(height: 15)
                    .padding()
            case .WaveformMorphedSynth:
                CustomSlider(value: $player.synthesizerManager.synthesizers[trackNumber - 1].uniqueModification, label: "Morph", range: 0 ... 3)
                    .frame(height: 15)
                    .padding()
            case.PhaseDisortedSynth:
                CustomSlider(value: $player.synthesizerManager.synthesizers[trackNumber - 1].uniqueModification, label: "Phase", range: -1 ... 1)
                    .frame(height: 15)
                    .padding()
            }
            Spacer()
                
        }
    }

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentSettings(trackNumber: 1)
    }
}
