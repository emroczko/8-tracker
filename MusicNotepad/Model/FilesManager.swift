//
//  FilesManager.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 21/11/2021.
//

import Foundation
import AVKit


struct FilesManager {
    
    static func deleteRecording(trackNumber: Int) {

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("track\(trackNumber)_bachelor_app.m4a")
        
        do {
           try FileManager.default.removeItem(at: fileName)
        } catch {
            print("File could not be deleted!")
        }
    }
    
    static func getFileURL(trackNumber: Int) -> URL{
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent("track\(trackNumber)_bachelor_app.m4a")
        
        return fileURL
    }
    
    static func checkIfFileExists(trackNumber: Int) -> Bool{
        let fileURL = getFileURL(trackNumber: trackNumber)
        
        guard FileManager.default.fileExists(atPath: fileURL.path)
        else { return false}
        
        return true
    }
    
    static func checkIfFileExists(fileURL: URL) -> Bool{
        
        guard FileManager.default.fileExists(atPath: fileURL.path)
        else { return false}
        
        return true
    }
    
    static func getDurationOfAudioFile(trackNumber: Int) -> String {
        let fileURL = getFileURL(trackNumber: trackNumber)
        guard checkIfFileExists(fileURL: fileURL)
        else { return "Empty" }
        
        let file = try! AVAudioFile(forReading: fileURL)
        
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        var duration = formatter.string(from: file.duration)!
        duration.removeFirst()
        
        return "Duration: " + duration
        
    }

}
