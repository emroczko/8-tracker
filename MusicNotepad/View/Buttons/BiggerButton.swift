//
//  DarkButtonWithImage.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 13/12/2021.
//

import SwiftUI

struct BiggerButton: View {
    var imageName: String?
    var title: String?
    var function: () -> Void
    var imageColor: Color
    var linearGradient : LinearGradient
    
    var body: some View {
        Button(action: {
            function()
        }){
            if(imageName != nil){
                Image(systemName: imageName!)
            }
            if(title != nil){
                Text(title!)
            }
        }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(imageColor)
            .background(linearGradient)
            .cornerRadius(30)
        
    }
}


struct BiggerButton_Previews: PreviewProvider {
    static var previews: some View {
        BiggerButton(imageName: "pianokeys.inverse", function: {}, imageColor: .blue, linearGradient: LinearGradient(colors: [Color.black.opacity(0.5)], startPoint: .trailing, endPoint: .leading))
    }
}
