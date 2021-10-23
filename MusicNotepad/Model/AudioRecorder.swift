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

class AudioRecorder: ObservableObject {
    
    var audioRecorder : AVAudioRecorder!
        
    @Published var isRecording : Bool = false

    @Published var recordingsList = [Recording]()
    
    func startRecording(){
        

            let recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("Can not setup the Recording")
            }
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = path.appendingPathComponent("CO-Voice : \(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
            
            
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                isRecording = true
                
            } catch {
                print("Failed to Setup the Recording")
            }
        }
        
        
        func stopRecording(){
            audioRecorder.stop()
            isRecording = false
        }

//    override init() {
//        super.init()
//        fetchRecordings()
//    }
//
//    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
//
//    var audioRecorder: AVAudioRecorder!
//
//    var recordings = [Recording]()
//
//    var recording = false {
//        didSet {
//            objectWillChange.send(self)
//        }
//    }
//
//    func startRecording() {
//        let recordingSession = AVAudioSession.sharedInstance()
//
//        do {
//            try recordingSession.setCategory(.playAndRecord, mode: .default)
//            try recordingSession.setActive(true)
//        } catch {
//            print("Failed to set up recording session")
//        }
//
//        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
//
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder.record()
//
//            recording = true
//        } catch {
//            print("Could not start recording")
//        }
//    }
//
//    func stopRecording() {
//        audioRecorder.stop()
//        recording = false
//
//        fetchRecordings()
//    }
//
//    func fetchRecordings() {
//        recordings.removeAll()
//
//        let fileManager = FileManager.default
//        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
//        for audio in directoryContents {
//            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
//            recordings.append(recording)
//        }
//
//        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
//
//        objectWillChange.send(self)
//    }
//
//    func deleteRecording(urlsToDelete: [URL]) {
//
//        for url in urlsToDelete {
//            print(url)
//            do {
//               try FileManager.default.removeItem(at: url)
//            } catch {
//                print("File could not be deleted!")
//            }
//        }
//
//        fetchRecordings()
//    }
}
