//
//  MidiNoteData+Extension.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 22/12/2021.
//

import Foundation
import AudioKit


extension MIDINoteData : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(noteNumber)
        hasher.combine(duration)
        hasher.combine(position)
            
    }
}

extension Duration : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(beats)
    }
}
