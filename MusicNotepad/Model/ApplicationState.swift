//
//  ApplicationState.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 25/10/2021.
//

import Foundation


class ApplicationState : ObservableObject{
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
}
