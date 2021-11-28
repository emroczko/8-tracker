//
//  AVMutableCompositionTrack+Extension.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 14/11/2021.
//

import Foundation
import AVFoundation
import AudioKit

extension AVMutableCompositionTrack{
    func append(url: URL) {
        let newAsset = AVURLAsset(url: url)
        let range = CMTimeRangeMake(start: CMTime.zero, duration: newAsset.duration)
        let end = timeRange.end
        print(end)
        if let track = newAsset.tracks(withMediaType: AVMediaType.audio).first {
            try! insertTimeRange(range, of: track, at: end)
        }
        
    }
}
