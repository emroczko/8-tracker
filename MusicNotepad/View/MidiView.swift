//
//  MidiNotesView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 19/12/2021.
//

import SwiftUI

struct MidiView: View {
    var numberOfBeats : Int
    @State var scale: CGFloat = 1.0
    
    var trackNumber: Int
    
    var body: some View {
        
        VStack{
            
            ScrollView(.vertical){
                
            ZStack{
            
            KeyboardView()
            ScrollView(.horizontal){

                ZStack {
                    
                    HorizontalGridView()
                
                    Rectangle()
                        .frame(width: 2, height: 5872)
                        .foregroundColor(Color.black.opacity(0.5))
                        .position(x: 40, y: 0)
                        .zIndex(100)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    ForEach(1...numberOfBeats, id: \.self) {
                        beat in
                        Rectangle()
                            .frame(width: beat % 4 == 0 ? 2 : 1, height: 8260)
                            .foregroundColor(Color.black.opacity(0.5))
                            .position(x: CGFloat(beat * 45 + 40), y: 0)
                            .zIndex(100)
                        
                        Spacer()
                            .frame(width: 20)
                    }
                    
                    MidiNotesView(trackNumber: trackNumber)
                }
                .frame(width: 1480, height: 4172)
                    
                
            }
            
                
            }
            
        }

        .background(Color.black.opacity(0.3))
        .cornerRadius(30)
        
        }
    }
}

struct MidiNotesView: View {
    @EnvironmentObject var manager : AudioManager
    var trackNumber: Int
    
    var body: some View {
        
        Rectangle()
            .frame(width: 45, height: 38)
            .cornerRadius(2)
            .foregroundColor(Color.green)
            .position(x: 140, y: 38 + 45)
            .zIndex(100)
        
//        ForEach(manager.tracksData[trackNumber - 1].midiNotes, id: \.self) { note in
//            Rectangle()
//                .frame(width: note.duration.beats * 45, height: 38)
//                .cornerRadius(2)
//                .foregroundColor(Color.green)
//                .position(x: note.position.beats * 45 + 140, y: CGFloat(108 - note.noteNumber) * 38 + 45)
//                .zIndex(100)
//                
//        }
    }
}


struct HorizontalGridView: View {
    
    var body: some View {
        Rectangle()
            .frame(width: 1500, height: 38)
            .foregroundColor(Color.black.opacity(0.4))
            .position(x: 790, y: 45)
            .cornerRadius(30)
            .zIndex(30)
        ForEach(1...107, id: \.self) {
            key in
            Rectangle()
                .frame(width: 1500, height: 38)
                .foregroundColor(Color.black.opacity(key % 2 == 1 ? 0.15 : 0.4))
                .position(x: 790, y: CGFloat(key * 38) + 45)
                .cornerRadius(30)
        }
        .zIndex(30)
    }
}


struct KeyboardView: View {
    var CSoundArray : [Int] = [7, 6, 5, 4, 3, 2, 1, 0 , -1, -2]
    
    var body: some View {

        Rectangle()
            .frame(width: 1500, height: 151)
            .foregroundColor(Color.black)
            .position(x: 0, y: -50)
            .zIndex(50)
        
        ForEach(0...8, id: \.self) {
            octave in
            OctaveView(offset: CGFloat(octave * 456), cSoundNumber: CSoundArray[octave])
        }
    }
}

struct OctaveView: View{
    var offset : CGFloat
    var cSoundNumber: Int
    
    var body : some View {
        
        WhiteKeysView(offset: offset, cSoundNumber: cSoundNumber)
        BlackKeysView(offset: offset)
        
        
    }
}

struct BlackKeysView : View {
    var offset : CGFloat
    var body: some View {
        ForEach(1...3, id: \.self) {
            key in
  
            Rectangle()
                .frame(width: 50, height: 38)
                .cornerRadius(2)
                .foregroundColor(Color.black)
                .position(x: 0, y: CGFloat(key * 76) + 7 + offset)
                .cornerRadius(30)
            
        }.zIndex(100)
        

        Rectangle()
            .frame(width: 50, height: 38)
            .cornerRadius(2)
            .foregroundColor(Color.black)
            .position(x: 0, y: 349 + offset)
            .zIndex(100)
        Rectangle()
            .frame(width: 50, height: 38)
            .cornerRadius(2)
            .foregroundColor(Color.black)
            .position(x: 0, y: 425 + offset)
            .zIndex(100)
    }
}

struct WhiteKeysView : View {
    var offset: CGFloat
    var cSoundNumber : Int
    
    var body: some View {
        Rectangle()
            .frame(width: 80, height: 65)
            .cornerRadius(2)
            .foregroundColor(Color.white.opacity(0.9))
            .position(x: 0, y: offset + 58.5)
            .zIndex(50)
        Rectangle()
            .frame(width: 77, height: 1)
            .cornerRadius(2)
            .foregroundColor(Color.black.opacity(0.5))
            .position(x: 0, y: offset + 91.5)
            .zIndex(100)
        
        ForEach(1...5, id: \.self) {
            key in
            Rectangle()
                .frame(width: 80, height: 65)
                .cornerRadius(2)
                .foregroundColor(Color.white.opacity(0.9))
                .position(x: 0, y: CGFloat(Double(key) * 65) + 59 + offset)
                .zIndex(50)
                
            Rectangle()
                .frame(width: 77, height: 1)
                .cornerRadius(2)
                .foregroundColor(Color.black.opacity(0.5))
                .position(x: 0, y: CGFloat(Double(key) * 65) + 91.5 + offset)
                .zIndex(100)
        }
        
        Rectangle()
            .frame(width: 80, height: 65)
            .cornerRadius(2)
            .foregroundColor(Color.white.opacity(0.9))
            .position(x: 0, y: CGFloat(6 * 65) + 59 + offset)
            .zIndex(50)
        
        Text("C\(cSoundNumber)")
            .position(x: 20, y: CGFloat(6 * 65) + 71 + offset)
            .foregroundColor(Color.black.opacity(0.3))
            .zIndex(60)
        
            
        Rectangle()
            .frame(width: 77, height: 1)
            .cornerRadius(2)
            .foregroundColor(Color.black.opacity(0.5))
            .position(x: 0, y: CGFloat(6 * 65) + 91.5 + offset)
            .zIndex(100)
    }
}


struct MidiNotesView_Previews: PreviewProvider {
    static var previews: some View {
        MidiView(numberOfBeats: 32, trackNumber: 1)
    }
}
