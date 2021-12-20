//
//  Binding+Extension.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 20/11/2021.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    func returnValue() -> Bool {
        return self.wrappedValue
    }
}

extension Binding where Value == TrackType {
    func returnValue() -> TrackType {
        return self.wrappedValue
    }
}
