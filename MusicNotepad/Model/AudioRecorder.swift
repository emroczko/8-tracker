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
import CoreAudio

class AudioRecorder: ObservableObject {
    
    var audioRecorder : AVAudioRecorder!
        
    @Published var isRecording : Bool = false

    @Published var recordingsList = [Recording]()
    
    var countTick = 0
    var timerCount : Timer?
    
    func startRecording(trackNumber: Int, tempo: Int){
        
            
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
                audioRecorder.record()
                isRecording = true
                
                timerCount = Timer.scheduledTimer(withTimeInterval: TimeInterval(60/tempo), repeats: true, block: { (value) in
                    self.countTick += 1
                    
                    if(self.countTick == 33){
                        self.stopRecording()
                    }
                    
                })
                
            } catch {
                print("Failed to Setup the Recording")
            }
        }
        
        
        func stopRecording(){
            print("stop")
            audioRecorder.stop()
            isRecording = false
        }

    func deleteRecording(trackNumber: Int) {

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("track\(trackNumber)_bachelor_app.m4a")
        
        do {
           try FileManager.default.removeItem(at: fileName)
        } catch {
            print("File could not be deleted!")
        }
    }
}
