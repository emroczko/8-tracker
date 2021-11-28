//
//  CustomButtonView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 26/10/2021.
//

import SwiftUI

struct CustomButtonView: View {
    var imageName: String
    var trackNumber: Int?
    var function: () -> Void
    var color: Color
    
    var body: some View {
        Spacer()
        Button(action: {
            function()
        }) {
            Image(systemName: imageName)
        }
        .frame(width: 20)
        .padding()
        .foregroundColor(color)
        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom))
        .opacity(0.9)
        .cornerRadius(30)
        Spacer()
    }
}

struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(imageName: "circle.fill", function: {}, color: Color.white)
    }
}
