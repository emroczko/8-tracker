//
//  AudioPlayer.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 21/10/2021.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = AudioPlayer()
    
    var players = [URL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    var accentPlayer: AVAudioPlayer!
    var regularPlayer: AVAudioPlayer!
    
    private override init() {
        print("konstruktor")
        let accentMetronomeFileURL = Bundle.main.url(forResource: "accentMetronome", withExtension: "wav")
        accentPlayer = try! AVAudioPlayer(contentsOf: accentMetronomeFileURL!)
        accentPlayer.volume = 100
        let regularMetronomeFileURL = Bundle.main.url(forResource: "regularMetronome", withExtension: "wav")
        regularPlayer = try! AVAudioPlayer(contentsOf: regularMetronomeFileURL!)
        regularPlayer.volume = 100
        
    }
    
    func prepareMetronome(){
        accentPlayer.prepareToPlay()
        regularPlayer.prepareToPlay()
    }
    
    func playAccentMetronome(interval: TimeInterval){
        print("accent")
        accentPlayer.play()
    }
    
    func playRegularMetronome(interval: TimeInterval){
        print("regular")
        regularPlayer.play()
    }
    
    func playTrack(trackNumber: Int){

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent("track\(trackNumber)_bachelor_app.m4a")
        
        guard FileManager.default.fileExists(atPath: fileURL.path)
        else { return }

        if let player = players[fileURL] {

            if player.isPlaying == false {
                player.prepareToPlay()
                player.volume = 100
                player.play()
            }
            else {

                let duplicatePlayer = try! AVAudioPlayer(contentsOf: fileURL)
                duplicatePlayer.delegate = self
                duplicatePlayers.append(duplicatePlayer)
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.volume = 100
                duplicatePlayer.play()

            }
        } else {
            do{
                let player = try AVAudioPlayer(contentsOf: fileURL)
                players[fileURL] = player
                player.prepareToPlay()
                player.volume = 100
                player.play()
            } catch {
                print("Could not play sound file!")
            }
        }
    }
    
    func playTracks(){
        for trackNumber in 1...8 {
            playTrack(trackNumber: trackNumber)
        }
    }
    
    func stopTracks(){
        players.removeAll()
        for player in duplicatePlayers {
            player.stop()
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at: (duplicatePlayers.firstIndex(of: player)!))
    }

    
}
