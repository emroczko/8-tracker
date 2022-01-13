//
//  ApplicationState.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 25/10/2021.
//

import Foundation


class ApplicationState : ObservableObject{
    static let shared = ApplicationState()
    
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isKeyboardVisible = false
    @Published var isMidiViewVisible = false
    
    private init(){}
}
