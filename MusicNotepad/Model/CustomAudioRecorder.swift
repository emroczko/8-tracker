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

class CustomAudioRecorder: ObservableObject {
    
    @Published var isRecording : Bool = false
    var appLength: Int = 32
    var currentTrackNumber: Int = 0
    var audioRecorder : AVAudioRecorder = AVAudioRecorder()
    
    func startRecording(trackNumber: Int){
        
        if(FilesManager.checkIfFileExists(trackNumber: trackNumber)){
            FilesManager.deleteRecording(trackNumber: trackNumber)
        }
        
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
        
        print("track\(trackNumber)_bachelor_app.m4a")
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            isRecording = true
            audioRecorder.record()
        } catch {
            print("Failed to Setup the Recording")
        }
    }
        
        
    func stopRecording(){
        print("stop")
        audioRecorder.stop()
        isRecording = false
    }
    
}
