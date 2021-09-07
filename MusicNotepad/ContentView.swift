//
//  ContentView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/09/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView{
            VStack{
                Capsule()
                    .padding()
                    .frame(width: 400, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/
                    )

                TrackView(title: "Track 1")
                TrackView(title: "Track 2")
                TrackView(title: "Track 3")
                TrackView(title: "Track 4")
                TrackView(title: "Track 5")
                TrackView(title: "Track 6")
                TrackView(title: "Track 7")
                TrackView(title: "Track 8")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TrackView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .frame(width: 300, height:
                    100, alignment: .center)
            .padding()
    }
}
