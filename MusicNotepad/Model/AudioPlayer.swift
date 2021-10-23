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
    
    init(url: URL){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : url)
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
