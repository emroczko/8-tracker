//
//  ContentView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/09/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
        
        ScrollView{
            VStack{
                ConsoleView()

                TrackView(title: "Track 1")
                TrackView(title: "Track 2")
                TrackView(title: "Track 3")
                TrackView(title: "Track 4")
                TrackView(title: "Track 5")
                TrackView(title: "Track 6")
                TrackView(title: "Track 7")
                TrackView(title: "Track 8")
            }
        }.padding(.top, 40)
        
        
        
        }
        .padding()
        .background(Color.black.opacity(0.9))
        .ignoresSafeArea()
        
        
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
        
        HStack {
            CusttomButton(imageName: "smallcircle.fill.circle")
            Text(title)
                .frame(width: 200, height:
                        UIScreen.screenHeight/12, alignment: .center)
                .padding()
                .foregroundColor(.blue)
            CusttomButton(imageName: "trash")
        }

        .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.blue, lineWidth: 1)
                )
        
        
        
    }
}

struct CusttomButton: View {
    var imageName: String
    
    var body: some View {
        Spacer()
        Button(action: {
            print("Button tapped")
        }) {
            Image(systemName: imageName)
        }
        .frame(width: 20)
        .padding()
        .foregroundColor(.white)
        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(30)
        Spacer()
    }
}

struct ConsoleView: View {
    var body: some View {
        HStack {
            CusttomButton(imageName: "play.circle")
            CusttomButton(imageName: "stop.circle")
        }
        .padding()
        .background(Color.black)
        .cornerRadius(30)
        
    }
}
