//
//  AudioPlayer.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 21/10/2021.
//

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    
    private var audioPlayer = AVAudioPlayer()
    
    init(name: String, type: String){
        if let url = Bundle.main.url(forResource: name, withExtension: type) {
            print("succes audio \(name)")
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.prepareToPlay()
                
            }
            catch{
                print("error getting audio")
            }
        }
    }
    
    init(){}
    
    func playSingleTrack(trackNumber: Int){
        
        let playSession = AVAudioSession.sharedInstance()
                
                do {
                    try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                } catch {
                    print("Playing failed in Device")
                }
        
        do {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = path.appendingPathComponent("track" + String(trackNumber) + "_bachelor_app.m4a")
              
            audioPlayer = try AVAudioPlayer(contentsOf : fileURL)
            audioPlayer.volume = 100
            audioPlayer.prepareToPlay()
            audioPlayer.play()
                
        } catch {
            print("Playing Failed")
        }
    }
    
    func play(){
        audioPlayer.play()
    }
    
    func stop(){
        audioPlayer.stop()
    }
}
