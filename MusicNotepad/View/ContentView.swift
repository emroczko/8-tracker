//
//  ContentView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/09/2021.
//

import SwiftUI
import AVKit
import AudioKit


let numberOfSamples: Int = 32



struct ContentView: View {
    
    @StateObject var applicationState = ApplicationState.shared
    @StateObject var player = AudioManager()
    
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
            VStack{
                ConsoleView()
                ScrollView{
                    VStack{
                        
                        ForEach(1...8, id: \.self) {
                            trackNumber in
                            TrackView(title: "Track " + String(trackNumber), trackNumber: trackNumber, trackFocus: $trackFocus)
                        }
                    }
                }
            }.padding(.top, 40)
        }
        .animation(.linear(duration: 0.3))
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
        .environmentObject(applicationState)
        .environmentObject(player)
        .onAppear {
            self.player.start()
        }
        .onDisappear {
            self.player.stop()
        }
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
        .frame(height: trackFocus[trackNumber] == true ? 0.5*UIScreen.screenHeight : 120)
        .background(Color.black.opacity(0.75))
        .cornerRadius(30)
    }
    
}

struct ExpandedTrackView: View {
    var title: String
    var trackNumber: Int
    var midiConverter: MidiConverter = MidiConverter()
    @Binding var trackFocus : [Int : Bool]
    @Binding var viewHeight: CGFloat
    @State var progressValue: Float = 0.0
    @ObservedObject var audioRecorder: CustomAudioRecorder = CustomAudioRecorder()
    @EnvironmentObject var player: AudioManager
    @State var isInstrumentSettingsExpanded: Bool = false
    
    
    @EnvironmentObject var applicationState: ApplicationState
    var timeProgress: Float = 0

    
    var body: some View {
        
        VStack{
        TabView {
            VStack {
                HStack {
                    Group{
                        if($player.data.isRecording.returnValue() == false){
                            CustomButtonView(imageName: "smallcircle.fill.circle",
                                          function: record, color: .red)
                        } else {
                            CustomButtonView(imageName: "stop.circle",
                                          function: stopRecording, color: .white)
                        }
                    }
                    .disabled(applicationState.isPlaying)
                    Group{
                        if(!player.data.tracksMuted[trackNumber]!){
                        CustomButtonView(imageName: "speaker.fill", function: muteTrack, color: .white)
                        }
                            else{
                            CustomButtonView(imageName: "speaker.slash.fill", function: muteTrack, color: .blue)
                        }
                        if(player.data.soloTrack == trackNumber){
                            CustomButtonView(imageName: "headphones", function: unSoloTrack, color: .yellow)
                        }
                        else{
                            CustomButtonView(imageName: "headphones", function: soloTrack, color: .white)
                        }
                        
                        CustomButtonView(imageName: "trash", function: deleteRecording, color: .gray)
                    }
                    .disabled(applicationState.isRecording || applicationState.isPlaying)
                }
                
                ProgressBar(value: $player.data.currentBeat, tempo: $player.data.tempo)
                    .frame(height: 15)
                    .padding()
                
                CustomSlider(value: $player.tracksData[trackNumber - 1].audioVolume, label: "Volume", bounds: 0.0 ... 100.0)
                    .frame(height: 15)
                    .padding()
                
                    


                if($player.tracksData[trackNumber - 1].isAudioRecorded.returnValue() == true){
                    MidiControlsButtons(trackNumber: trackNumber)
                }
            }
            .tabItem{
                
            }
            
            InstrumentSettings(trackNumber: trackNumber)
            .tabItem {
                
            }
        }
        .tabViewStyle(PageTabViewStyle())
            
        Button(action: {
            trackFocus = trackFocus.mapValues({ _ in false })
            viewHeight = 0.4*UIScreen.screenWidth
        }){
            Image(systemName: "chevron.up")
        }
        .padding()
        .disabled(applicationState.isRecording)
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
    
    func muteTrack(){
        player.data.tracksMuted[trackNumber]?.toggle()
    }
    
    func record() {
        player.data.trackToRecord = trackNumber
        player.data.isRecording = true
        player.data.isPlaying = true
        applicationState.isRecording = true
    }
    
    func stopRecording() {
        player.stopRecording()
        player.stopTracks()
        player.data.trackToRecord = 0
        player.data.isPlaying = false
        applicationState.isRecording = false
        player.sequencer.rewind()
        
    }
    
    func soloTrack() {
        player.data.soloTrack = trackNumber
    }
    
    func unSoloTrack(){
        player.data.soloTrack = 0
    }
    
    func deleteRecording() {
        player.clearTrack(trackNumber: trackNumber)
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
            HStack {
                Text(title)
                    .frame(width: UIScreen.screenWidth/10*4.25, height:
                            UIScreen.screenHeight/12, alignment: .center)
                    
                .foregroundColor(.blue)
    
                Text(FilesManager.getDurationOfAudioFile(trackNumber: trackNumber))
                    .frame(width: UIScreen.screenWidth/10*4.25, height:
                            UIScreen.screenHeight/12, alignment: .center)
                    .foregroundColor(.blue)
                
            }
            Button(action: {
                trackFocus = trackFocus.mapValues({ _ in false })
                trackFocus.updateValue(true, forKey: trackNumber)
                viewHeight = 320
            }){
                Image(systemName: "chevron.down")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .disabled(applicationState.isRecording)
    }
}

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


struct ConsoleView: View {
    
    @EnvironmentObject var applicationState: ApplicationState
    @State var backgroundColor: Color = Color.black.opacity(0.75)
    @State var viewHeight: CGFloat = 100
    @State var isExpanded: Bool = false
    
    @EnvironmentObject var player: AudioManager
    
    var body: some View {
        VStack {
            HStack {
                CustomButtonView(imageName: "play.circle", function: start, color: applicationState.isPlaying ? .white : .green)
                    .disabled($applicationState.isPlaying.returnValue() == true)
                
                CustomButtonView(imageName: "stop.circle", function: stop, color: applicationState.isPlaying ? .red : .white)
                    .disabled($applicationState.isPlaying.returnValue() == false)
            }
            
            if (isExpanded == false) {
                Spacer()
                Button(action: {
                    viewHeight = 328
                    isExpanded = true
                }){
                    Image(systemName: "chevron.down")
            }
            } else {
                Spacer()
                    .frame(height: 10)
                HStack{
                    Button("Click", action: {
                        player.data.isMetronomePlaying.toggle()
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.blue)
                    .background(Color.black.opacity(player.data.isMetronomePlaying ? 0.5 : 0.2))
                    .cornerRadius(30)
                    .foregroundColor(Color.black.opacity(0.75))
                    
                    Button("Count in", action: {
                        player.data.isCountIn.toggle()
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.blue)
                    .background(Color.black.opacity(player.data.isCountIn ? 0.5 : 0.2))
                    .cornerRadius(30)
                    .foregroundColor(Color.black.opacity(0.75))
                    .disabled(applicationState.isPlaying == true)
                }
                
                Stepper(value: $player.data.tempo, in: 100...120) {
                    Text("Tempo: \(player.data.tempo, specifier: "%.0f")")
                }
                .foregroundColor(Color.blue)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(30)
                Button("Loop", action: {
                    player.data.isLooped.toggle()
                })
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.blue)
                .background(Color.black.opacity(player.data.isLooped ? 0.5 : 0.2))
                .cornerRadius(30)
                .foregroundColor(Color.black.opacity(0.75))
 
                Button(action: {
                    viewHeight = 100
                    isExpanded = false
                })
                {
                    Image(systemName: "chevron.up")
                }
                .padding()
            }
                
        }
        .padding()
        .frame(height: viewHeight)
        .background(applicationState.isPlaying || applicationState.isRecording ? player.data.color : backgroundColor)
        .cornerRadius(30)
        .disabled(applicationState.isRecording)
        
    }
    
    func start() {
        player.data.isPlaying = true
        applicationState.isPlaying = true
        
    }
    
    func stop() {
        player.stopTracks()
        player.data.isPlaying = false
        applicationState.isPlaying = false
        player.sequencer.rewind()
    }
}
    
struct DarkButtonView: View {
    @State var title: String
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

struct MidiControlsButtons: View {
    var trackNumber: Int
    @State var convertToMidiPressed : Bool = false
    var midiConverter: MidiConverter = MidiConverter()
    
    @EnvironmentObject var player: AudioManager
    
    var body: some View {
        
        if (FilesManager.checkIfFileExists(trackNumber: trackNumber)) {
            HStack{
            DarkButtonView(title: "Audio", isPressed: $player.tracksData[trackNumber - 1].isAudioEnabled, function: enableAudio)
            DarkButtonView(title: "MIDI", isPressed:  $player.tracksData[trackNumber - 1].isMidiEnabled,function: enableMidi)
            }
        }
        
    }
    
    func enableAudio(){
        player.tracksData[trackNumber - 1].isAudioEnabled.toggle()
    }
    
    func enableMidi(){
        if(player.midiNotes[trackNumber]!.isEmpty){
            convertToMidi()
            print("converting")
        }
        player.tracksData[trackNumber - 1].isMidiEnabled.toggle()
        if(player.tracksData[trackNumber - 1].isMidiEnabled == false){
            player.sequencer.tracks[trackNumber + 3].clear()
        }
        
    }
    
    func convertToMidi(){
        let notes = midiConverter.convertBufferToFloats(trackNumber: trackNumber)
        guard notes.count > 0 else {
            return
        }
        player.addMidiToTrack(trackNumber: trackNumber, notes: notes)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
