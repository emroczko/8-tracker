//
//  ContentView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/09/2021.
//

import SwiftUI
import AVKit




struct ContentView: View {
    
//    @ObservedObject var audioRecorder: AudioRecorder
    @StateObject var applicationState = ApplicationState()
    
    @State var trackFocus : [Int : Bool] = [1 : false,
                                            2 : false,
                                            3 : false,
                                            4 : false,
                                            5 : false,
                                            6 : false,
                                            7 : false,
                                            8 : false]
    
    
    var body: some View {
        
        ZStack{
            ScrollView{
                VStack{
                    ConsoleView()
                    TrackView(title: "Track 1", trackNumber: 1, trackFocus: $trackFocus)
                    TrackView(title: "Track 2", trackNumber: 2, trackFocus: $trackFocus)
                    TrackView(title: "Track 3", trackNumber: 3, trackFocus: $trackFocus)
                    TrackView(title: "Track 4", trackNumber: 4, trackFocus: $trackFocus)
                    TrackView(title: "Track 5", trackNumber: 5, trackFocus: $trackFocus)
                    TrackView(title: "Track 6", trackNumber: 6, trackFocus: $trackFocus)
                    TrackView(title: "Track 7", trackNumber: 7, trackFocus: $trackFocus)
                    TrackView(title: "Track 8", trackNumber: 8, trackFocus: $trackFocus)
                }
            }.padding(.top, 40)
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
    }
}

struct TrackView: View {
    var title: String
    var trackNumber: Int
    @Binding var trackFocus : [Int : Bool]
    @State var isExpanded: Bool = false
    @State var viewHeight: CGFloat = 120
    
    var body: some View {
        
        ExpandedTrackView(title: title, trackNumber: trackNumber, isExpanded: trackFocus[trackNumber] == true ? isExpanded : false)
            .frame(height: trackFocus[trackNumber] == true ? 240 : 120 )
        .background(Color.black.opacity(0.75))
        .cornerRadius(30)
        .disabled(true)
        .onTapGesture {
            isExpanded = trackFocus[trackNumber] == true ? isExpanded : false
            updateTrackFocus()
            if (!isExpanded){
                viewHeight = 240
                isExpanded = true
            }
            else{
                viewHeight = 120
                isExpanded = false
            }
        }
        .animation(.linear(duration: 0.2))
        
    }
    
    func updateTrackFocus(){
        if(trackFocus[trackNumber] == true){
            trackFocus = trackFocus.mapValues({ _ in false })
        }
        else{
            trackFocus = trackFocus.mapValues({ _ in false })
            trackFocus.updateValue(true, forKey: trackNumber)
        }
    }
    
}

struct ExpandedTrackView: View {
    var title: String
    var trackNumber: Int
    var isExpanded: Bool = false
    
    var body: some View {
        Group{
        HStack {
            if(!isExpanded){
                Text(title)
                    .frame(width: UIScreen.screenWidth/5*4.25, height:
                            UIScreen.screenHeight/12, alignment: .center)
                    .padding()
                    .foregroundColor(.blue)
            }else{
            CusttomButton(imageName: "smallcircle.fill.circle",
                          function: doSth)
            CusttomButton(imageName: "trash", function: doSth)
            }
        }
        }
    }
    
    func doSth() -> Void {
        print("function")
    }
}

struct CusttomButton: View {
    var imageName: String
    var trackNumber: Int?
    var function: () -> Void
    
    var body: some View {
        Spacer()
        Button(action: {
            function()
        }) {
            Image(systemName: imageName)
        }
        .frame(width: 20)
        .padding()
        .foregroundColor(.white)
        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom))
        .opacity(0.9)
        .cornerRadius(30)
        Spacer()
    }
}

struct ConsoleView: View {
    
    @ObservedObject var accentPlayer = AudioPlayer(name: "accentMetronome", type: "wav")
    @ObservedObject var regularPlayer = AudioPlayer(name: "regularMetronome", type: "wav")

    @State var timer: Timer? = nil
    
    @State var isPlaying: Bool = false
    let visualTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @State var backgroundColor: Color = Color.black.opacity(0.75)
     
    var body: some View {
        HStack {
            CusttomButton(imageName: "play.circle", function: startMetronome)
                .disabled(isPlaying)
            CusttomButton(imageName: "stop.circle", function: stopMetronome)
                .disabled(!isPlaying)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(30)
        
    }
    
    func startMetronome() -> Void {
        var count: Int = 0
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            count += 1
            
            if(count % 4 == 1){
                visualMetronome(color: Color.pink
                                    .opacity(0.75))
                accentPlayer.play()
            }
            else{
                visualMetronome(color: Color.blue
                                    .opacity(0.75))
                regularPlayer.play()

            }
            if(count == 16){
                timer.invalidate()
                isPlaying = false
            }
            
        }
    }
    
    func stopMetronome() -> Void {
        isPlaying = false
        timer?.invalidate()
    }
    
    func visualMetronome(color : Color){
        backgroundColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            backgroundColor = Color.black.opacity(0.75)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


