//
//  ContentView.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/09/2021.
//

import SwiftUI
import AVKit
import AudioKit
import AudioKitUI


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
                if($applicationState.isKeyboardVisible.returnValue()){
                    TrackView(title: "Track " + String(player.data.trackToRecord), trackNumber: player.data.trackToRecord, trackFocus: $trackFocus)
                    KeyboardWidget(delegate: player, firstOctave: 1, octaveCount: 2, polyphonicMode: false)
                        .cornerRadius(30)
                }
                else{
                    ScrollView{
                        VStack{
                            ForEach(1...8, id: \.self) {
                                trackNumber in
                                TrackView(title: "Track " + String(trackNumber), trackNumber: trackNumber, trackFocus: $trackFocus)
                            }
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

struct ConsoleView: View {
    
    @EnvironmentObject var applicationState: ApplicationState
    @State var backgroundColor: Color = Color.black.opacity(0.75)
    @State var viewHeight: CGFloat = 100
    @State var isExpanded: Bool = false
    
    @EnvironmentObject var player: AudioManager
    
    var body: some View {
        VStack {
            HStack {
                RoundButton(imageName: "play.circle", function: start, color: applicationState.isPlaying ? .white : .green)
                    .disabled($applicationState.isPlaying.returnValue() == true)
                
                RoundButton(imageName: "stop.circle", function: stop, color: applicationState.isPlaying ? .red : .white)
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
                            RoundButton(imageName: "smallcircle.fill.circle",
                                          function: record, color: .red)
                        } else {
                            RoundButton(imageName: "stop.circle",
                                          function: stopRecording, color: .white)
                        }
                    }
                    .disabled(applicationState.isPlaying)
                    Group{
                        if(!player.data.tracksMuted[trackNumber]!){
                        RoundButton(imageName: "speaker.fill", function: muteTrack, color: .white)
                        }
                            else{
                            RoundButton(imageName: "speaker.slash.fill", function: muteTrack, color: .blue)
                        }
                        if(player.data.soloTrack == trackNumber){
                            RoundButton(imageName: "headphones", function: unSoloTrack, color: .yellow)
                        }
                        else{
                            RoundButton(imageName: "headphones", function: soloTrack, color: .white)
                        }
                        
                        RoundButton(imageName: "trash", function: deleteRecording, color: .gray)
                    }
                    .disabled(applicationState.isRecording || applicationState.isPlaying)
                }
                
                ProgressBar(value: $player.data.currentBeat, tempo: $player.data.tempo)
                    .frame(height: 15)
                    .padding()
                
                CustomSlider(value: $player.tracksData[trackNumber - 1].audioVolume, label: "Volume", range: 0.0 ... 100.0)
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
            
        HStack{
            if($applicationState.isKeyboardVisible.returnValue() == false){
                BiggerButton(imageName: "pianokeys.inverse", function: showKeys, imageColor: .blue, linearGradient: LinearGradient(colors: [Color.black.opacity(0.5)], startPoint: .trailing, endPoint: .leading))
                    .padding(.trailing)
                    .padding(.leading)
            }
            else{
                BiggerButton(imageName: "pianokeys", function: hideKeys, imageColor: .white, linearGradient: LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.75), Color.blue.opacity(0.75)]), startPoint: .top, endPoint: .bottom))
                    .padding(.trailing)
                    .padding(.leading)
            }
            
        }
            
        
        
        Button(action: {
            trackFocus = trackFocus.mapValues({ _ in false })
            viewHeight = 0.4*UIScreen.screenWidth
            applicationState.isKeyboardVisible = false
        }){
            Image(systemName: "chevron.up")
        }
        .padding()
        .disabled(applicationState.isRecording)
        }
    }
    
    func showKeys(){
        viewHeight = 0.7*UIScreen.screenHeight
        player.data.trackToRecord = trackNumber
        applicationState.isKeyboardVisible = true
    }
    
    func hideKeys(){
        applicationState.isKeyboardVisible = false
        viewHeight = 0.5*UIScreen.screenHeight
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

struct MidiControlsButtons: View {
    var trackNumber: Int
    var midiConverter: MidiConverter = MidiConverter()
    
    @EnvironmentObject var player: AudioManager
    
    var body: some View {
        VStack{
        if (FilesManager.checkIfFileExists(trackNumber: trackNumber)) {
            HStack {
                ZStack{
                    Capsule()
                        .opacity(0)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(30)
                        .frame(height: 55)
                        .padding(.leading)
                        .padding(.trailing)
                        
                    HStack(spacing: 0){
                        Text("Audio")
                            .foregroundColor(.blue)
                            .padding()
                        
                        Toggle("", isOn: $player.tracksData[trackNumber - 1].isAudioEnabled)
                        .foregroundColor(.blue)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .frame(width: 60)
                        .padding()
                    }
                }
                ZStack{
                    Capsule()
                        .opacity(0)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(30)
                        .frame(height: 55)
                        .padding(.leading)
                        .padding(.trailing)
                    HStack(spacing: 0){
                        Text("Midi")
                            .foregroundColor(.blue)
                            .padding()
                        
                        Toggle("", isOn: $player.tracksData[trackNumber - 1].isMidiEnabled)
                        .foregroundColor(.blue)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .frame(width: 60)
                        .padding()
                        .onChange(of: player.tracksData[trackNumber - 1].isMidiEnabled) { newValue in
                            enableMidi()
                        }
                    }
                }
                
            }
        }
        }
        
    }
    
    func enableMidi(){
        if(player.midiNotes[trackNumber]!.isEmpty){
            convertToMidi()
            print("converting")
        }
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
