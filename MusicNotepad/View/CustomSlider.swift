//
//  SwiftUIView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 13/12/2021.
//

import SwiftUI
import AudioKit

struct CustomSlider: View {
    
    @Binding var value: AUValue
    @State private var xOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    var label: String
    var bounds: ClosedRange<Float> = 0.0 ... 1.0
    var step: Float = 0.01
    
    @EnvironmentObject var player: AudioManager
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().frame(width: geometry.size.width, height: min(geometry.size.height/2, 10))
                        .opacity(0.3)
                        .foregroundColor(.black)
                        .cornerRadius(45.0)
                    
                    LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom)
                        .frame(width: min(xOffset + 10, geometry.size.width), height: min(geometry.size.height/2, 10))
                            .foregroundColor(Color(UIColor.systemPink))
                            .cornerRadius(45.0)
                    Circle()
                        .foregroundColor(Color(UIColor.black))
                        .frame(width: CGFloat(20), height: CGFloat(20), alignment: .center)
                        .offset(x: min(xOffset, geometry.size.width - 10))
                        .highPriorityGesture(DragGesture(minimumDistance: 0).onChanged({ gestureValue in
                            
                            if abs(gestureValue.translation.width) < 0.1 {
                                lastOffset = xOffset
                            }
                            let availableWidth = geometry.size.width
                            xOffset = max(0, min(lastOffset +  gestureValue.translation.width, availableWidth))
                            let newValue = (bounds.upperBound - bounds.lowerBound) * Float(xOffset / availableWidth) + bounds.lowerBound
                            let steppedNewValue = (round(newValue / step) * step)
                            value = min(bounds.upperBound, max(bounds.lowerBound, steppedNewValue))
                        }))
                    
                }
                .onAppear(){
                    let percentage = 1 - (bounds.upperBound - value) / (bounds.upperBound - bounds.lowerBound)
                    xOffset = geometry.size.width * CGFloat(percentage)
                    lastOffset = xOffset
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
            }
            Text(label)
                .foregroundColor(.blue)
                .padding()
        }
    }
}

struct CustomSliderPreviewProvider: View {
    @State var testValue: AUValue = 0.5
    
    var body: some View {
        CustomSlider(value: $testValue, label: "Test")
    }
}

struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomSliderPreviewProvider()
    }
}
