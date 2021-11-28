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

class CustomAudioRecorder: ObservableObject {
    
    var audioRecorder : AVAudioRecorder = AVAudioRecorder()
        
    @Published var isRecording : Bool = false

    @Published var recordingsList = [Recording]()
    
    var appLength: Int = 32
    
    var currentTrackNumber: Int = 0
    
    
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
        print("track\(trackNumber)_bachelor_app.m4a")
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            //audioRecorder.delegate = self
            isRecording = true
            audioRecorder.record()
        //forDuration: TimeInterval(appLength*60/tempo))

        } catch {
            print("Failed to Setup the Recording")
        }
    }
        
        
    func stopRecording(){
        print("stop")
        audioRecorder.stop()
        isRecording = false
    }
    
    func concatenateWithSilence() {
        
        let silenceFileURL = Bundle.main.url(forResource: "silence", withExtension: "m4a")
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = path.appendingPathComponent("track" + String(currentTrackNumber) + "_bachelor_app.m4a")
        let outputAudioURL = path.appendingPathComponent("track" + String(currentTrackNumber) + "_bachelor_app_merged.m4a")
        
        guard silenceFileURL != nil else {
            return
        }
        
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        compositionAudioTrack!.append(url: audioURL)
        compositionAudioTrack!.append(url: silenceFileURL!)

        if let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) {
            assetExport.outputFileType = AVFileType.m4a
            assetExport.outputURL = outputAudioURL
            assetExport.exportAsynchronously(completionHandler: {})
        }
    }
    
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        isRecording = false
//        concatenateWithSilence()
//    }
}
