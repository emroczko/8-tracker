//
//  SwiftUIView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 26/11/2021.
//

import SwiftUI

struct InstrumentSettings: View {
    @EnvironmentObject var player: AudioManager
    var trackNumber: Int
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 50)
            Picker(selection: .constant(1), label: Text("Picker"), content: {
                
                Text("Phase disorted synth").tag(1)
                    .foregroundColor(.blue)
                Text("Waveform morphed synth").tag(2)
                    .foregroundColor(.blue)
                Text("PWM synth").tag(3)
                    .foregroundColor(.blue)
                
            })
                .pickerStyle(.wheel)
            CustomSlider(value: $player.synthesizers[trackNumber - 1].amplitude, label: "Volume")
                .frame(height: 15)
                .padding()
            CustomSlider(value: $player.synthesizers[trackNumber - 1].amplitude, label: "Mod")
                .frame(height: 15)
                .padding()
            Spacer()
                .frame(height: 50)
        }
        
        
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentSettings(trackNumber: 1)
    }
}
