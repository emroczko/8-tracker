//
//  DarkButton.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 13/12/2021.
//

import SwiftUI

struct DarkButtonDynamic: View {
    var title: String
    @Binding var isPressed : Bool
    var function: () -> Void
    
    var body: some View {
        Button(title, action: {
            function()
        })
            .padding()
            .foregroundColor(Color.blue)
            .background(Color.black.opacity(isPressed ? 0.2 : 0.5))
            .cornerRadius(30)
            .foregroundColor(Color.black.opacity(0.75))
    }
}

struct DarkButtonMock : View {
    @State var isPressed : Bool = true
    
    var body: some View {
        DarkButtonDynamic(title: "Test", isPressed: $isPressed) {
            
        }
    }
}


struct DarkButton_Previews: PreviewProvider {
    static var previews: some View {
        DarkButtonMock()
    }
}
