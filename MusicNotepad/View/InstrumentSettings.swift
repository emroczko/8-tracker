//
//  SwiftUIView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 26/11/2021.
//

import SwiftUI

struct InstrumentSettings: View {
    var body: some View {
            Picker(selection: .constant(1), label: Text("Picker"), content: {
                
                Text("Phase disorted synth").tag(1)
                    .foregroundColor(.blue)
                Text("Waveform morphed synth").tag(2)
                    .foregroundColor(.blue)
                Text("PWM synth").tag(3)
                    .foregroundColor(.blue)
                
            })
            
                .pickerStyle(.wheel)
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentSettings()
    }
}
