//
//  ProgressBar.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 14/12/2021.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Float
    @Binding var tempo: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width/31, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(
                        .linear(duration: Double(60/tempo)))
            }.cornerRadius(45.0)
        }
    }
}

struct ProgressBarMock : View {
    @State var value: Float = 0
    @State var tempo: Double = 120
    
    var body: some View {
        ProgressBar(value: $value, tempo: $tempo)
    }
    
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarMock()
    }
}
