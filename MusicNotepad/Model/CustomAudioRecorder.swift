//
//  AudioRecorder.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 10/09/2021.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import AudioKitEX
import CoreAudio
import SoundpipeAudioKit
import AudioKit

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
    var number: Int = 0
}

struct PitchInformation {
    var dataTable: [Int: [Float]] = [1: [],
                                     2: [],
                                     3: [],
                                     4: [],
                                     5: [],
                                     6: [],
                                     7: [],
                                     8: []]
    
    mutating func append(trackNumber: Int, value: Float){
        dataTable[trackNumber]?.append(value)
    }
}

class CustomAudioRecorder: ObservableObject {
    
    @Published var isRecording : Bool = false
    var appLength: Int = 32
    var currentTrackNumber: Int = 0
    var tracker: PitchTap!
    let pitchEngine = AudioEngine()
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    var silencePitch: Fader
    var audioRecorder : AVAudioRecorder = AVAudioRecorder()
    
    
    
    @Published var pitchInformation = PitchInformation()
    @Published var data = TunerData()
    
    init(){

        guard let input = pitchEngine.input else {
            fatalError()
        }
        
        silencePitch = Fader(input, gain: 0)
        pitchEngine.output = silencePitch
    

        tracker = PitchTap(input) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
    }
    

    func update(_ pitch: AUValue, _ amp: AUValue) {
        data.pitch = pitch
        data.amplitude = amp
        data.number+=1
        
  
        pitchInformation.append(trackNumber: currentTrackNumber, value: pitch)
        
        
        print("pitch: \(pitch) :number: \(data.number) :trnumber: \(currentTrackNumber)")

        var frequency = pitch
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }

        var minDistance: Float = 10_000.0
        var index = 0

        for possibleIndex in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
            if distance < minDistance {
                index = possibleIndex
                minDistance = distance
            }
        }
        let octave = Int(log2f(pitch / frequency))
        data.noteNameWithSharps = "\(noteNamesWithSharps[index])\(octave)"
        data.noteNameWithFlats = "\(noteNamesWithFlats[index])\(octave)"
    }
    
    
    func startRecording(trackNumber: Int){
        
        
        currentTrackNumber = trackNumber
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("track" + String(trackNumber) + "_bachelor_app.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        //try! recordingEngine.start()
        try! pitchEngine.start()
        
        print("track\(trackNumber)_bachelor_app.m4a")
        
//        guard let input = recordingEngine.input else {
//            fatalError()
//        }
//
//        let audioFile = try! AVAudioFile(forWriting: fileName, settings: settings)
//
//
        
        
        do {
            
            //recorder = try NodeRecorder(node: input, file: audioFile, bus: 0)
            
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            isRecording = true
            tracker.start()
            //try recorder?.record()

            audioRecorder.record()
        } catch {
            print("Failed to Setup the Recording")
        }
    }
        
        
    func stopRecording(){
        print("stop")
        //recorder?.stop()
        audioRecorder.stop()
        tracker.stop()
        //recordingEngine.stop()
        pitchEngine.stop()
        isRecording = false
    }
    
}
