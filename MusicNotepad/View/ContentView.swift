//
//  ContentView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/09/2021.
//

import SwiftUI
import AVKit


let numberOfSamples: Int = 32



struct ContentView: View {
    
    @StateObject var applicationState: ApplicationState = ApplicationState()
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
                    ForEach(1...8, id: \.self) {
                        trackNumber in
                        TrackView(title: "Track " + String(trackNumber), trackNumber: trackNumber, trackFocus: $trackFocus)
                    }
                }
            }.padding(.top, 40)
            
        }
        .animation(.linear(duration: 0.3))
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
        .environmentObject(applicationState)
    }
    
}

struct TrackView: View {
    var title: String
    var trackNumber: Int
    @Binding var trackFocus : [Int : Bool]
    @State var viewHeight: CGFloat = 120
    
    var body: some View {
        Group{
            if(trackFocus[trackNumber] == false){
                CondensedTrackView(title: title, trackNumber: trackNumber, trackFocus: $trackFocus, viewHeight: $viewHeight)
            }
            else{
                ExpandedTrackView(title: title, trackNumber: trackNumber, trackFocus: $trackFocus, viewHeight: $viewHeight)
            }
        }
        .animation(.linear(duration: 0.3))
        .frame(height: trackFocus[trackNumber] == true ? 360 : 120 )
        .background(Color.black.opacity(0.75))
        .cornerRadius(30)
    
        
    }
    
}

struct ExpandedTrackView: View {
    var title: String
    var trackNumber: Int
    @Binding var trackFocus : [Int : Bool]
    @Binding var viewHeight: CGFloat
    @State var progressValue: Float = 0.0
    @ObservedObject var audioRecorder: AudioRecorder = AudioRecorder()
    @EnvironmentObject var applicationState: ApplicationState
    var timeProgress: Float = 0
    

    var body: some View {
                
        VStack {
            Spacer().frame(height:15)
                .padding()
            HStack {
                Group{
                    if(audioRecorder.isRecording == false){
                        CustomButtonView(imageName: "smallcircle.fill.circle",
                                      function: record)
                    } else {
                        CustomButtonView(imageName: "stop.circle",
                                      function: stopRecording)
                    }
                }
                .disabled(applicationState.isPlaying)
                Group{
                    CustomButtonView(imageName: "headphones", function: listenSingleRecording)
                    CustomButtonView(imageName: "trash", function: deleteRecording)
                }
                .disabled(applicationState.isRecording || applicationState.isPlaying)
            }
            Spacer()
            HStack {
                ForEach(1...numberOfSamples, id: \.self) { level in
                        BarView(value: 100)
                }
            }
            ProgressBar(value: $progressValue).frame(height: 15)
            .padding()
            Button(action: {
                trackFocus = trackFocus.mapValues({ _ in false })
                viewHeight = 120
            }){
                Image(systemName: "chevron.up")
            }
            .padding()
        }
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
    
    func record() {
        print("record func")
        self.audioRecorder.startRecording(trackNumber: self.trackNumber, tempo: 120)
    }
    
    func stopRecording() {
        print("stop func")
        self.audioRecorder.stopRecording()
    }
    
    func listenSingleRecording() {
        AudioPlayer.sharedInstance.playTrack(trackNumber: self.trackNumber)
    }
    
    func deleteRecording() {
        self.audioRecorder.deleteRecording(trackNumber: trackNumber)
    }
}

struct CondensedTrackView: View {
    var title: String
    var trackNumber: Int
    @Binding var trackFocus : [Int : Bool]
    @Binding var viewHeight: CGFloat
    @EnvironmentObject var applicationState: ApplicationState
    
    var body: some View {
        VStack{
            Spacer()
            Text(title)
                .frame(width: UIScreen.screenWidth/5*4.25, height:
                        UIScreen.screenHeight/12, alignment: .center)
                
                .foregroundColor(.blue)
            Button(action: {
                trackFocus = trackFocus.mapValues({ _ in false })
                trackFocus.updateValue(true, forKey: trackNumber)
                viewHeight = 360
            }){
                Image(systemName: "chevron.down")
            }
        }
        .padding()
        .disabled(applicationState.isRecording)
    }
}

struct BarView: View {

    var value: CGFloat

    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                                     startPoint: .top,
                                     endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 11) / CGFloat(numberOfSamples), height: value)
        }
    }
}

struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                            .opacity(0.3)
                            .foregroundColor(Color(UIColor.systemTeal))
                        
                        Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                            .foregroundColor(Color(UIColor.systemBlue))
                            .animation(.linear)
                    }.cornerRadius(45.0)
                }
    }
}

struct ConsoleView: View {
    
    @EnvironmentObject var applicationState: ApplicationState
    @State var backgroundColor: Color = Color.black.opacity(0.75)
    @State var viewHeight: CGFloat = 100
    @State var nextTick: DispatchTime = DispatchTime.distantFuture
    @State var count: Int = 0
    @State var isExpanded: Bool = false
    
    @State var timer: Timer!
    
    var onTick: ((_ nextTick: DispatchTime) -> Void)?
     
    var body: some View {
        VStack {
            HStack {
                CustomButtonView(imageName: "play.circle", function: start)
                    .disabled(applicationState.isPlaying)
                
                CustomButtonView(imageName: "stop.circle", function: stop)
                    .disabled(!applicationState.isPlaying)
            }
            
            if (isExpanded == false) {
                Spacer()
                Button(action: {
                    viewHeight = 300
                    isExpanded = true
                }){
                    Image(systemName: "chevron.down")
            }
            } else {
                Spacer()
//                Toggle("Metronome", isOn: $isExpanded)
//                    .toggleStyle(.button)
//                    .tint(.mint)
                Spacer()
                Button(action: {
                    viewHeight = 100
                    isExpanded = false
                }){
                    Image(systemName: "chevron.up")
            }
            }
        }
        .padding()
        .frame(height: viewHeight)
        .background(backgroundColor)
        .cornerRadius(30)
        .disabled(applicationState.isRecording)
        
    }
    
    private func start() {
        applicationState.isPlaying = true
        nextTick = DispatchTime.now()
        AudioPlayer.sharedInstance.prepareMetronome()
        nextTick = DispatchTime.now()
        tick()
    }

    private func stop() {
        applicationState.isPlaying = false
        count = 0
        AudioPlayer.sharedInstance.stopTracks()
        print("Stoping metronome")
    }
    
    private func tick() {
        guard
            applicationState.isPlaying,
            nextTick <= DispatchTime.now()
            else { return }

        let interval: TimeInterval = 60.0 / TimeInterval(120)
        self.nextTick = self.nextTick + interval
        DispatchQueue.main.asyncAfter(deadline: nextTick) {
            self.tick()
        }
        count += 1
        if(count == 1){
            DispatchQueue.main.async {
                AudioPlayer.sharedInstance.playTracks()
            }
        }
        
        if(count % 4 == 1){
            visualMetronome(color: Color.pink
                                .opacity(0.75))
            AudioPlayer.sharedInstance.playAccentMetronome(interval: interval)
        }
        else{
            visualMetronome(color: Color.blue
                                .opacity(0.75))
            AudioPlayer.sharedInstance.playRegularMetronome(interval: interval)

        }
        if(count == 16){
            applicationState.isPlaying = false
            count = 0
        }
        onTick?(nextTick)
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




