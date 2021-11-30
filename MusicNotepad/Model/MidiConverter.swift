//
//  MidiConverter.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 28/11/2021.
//

import Foundation
import AVKit
import CSoundpipeAudioKit
//import Beethoven
//import SoundpipeAudioKit

//(signal: [Float], rate: Double, frameCount: Int)
//(signal: [], rate: 0, frameCount: 0)

class MidiConverter {
    
    static var sharedInstance = MidiConverter()
    
    private var pitch: [Float] = [0, 0]
    private var amp: [Float] = [0, 0]
    private var trackers: [PitchTrackerRef] = []

    /// Detected amplitude (average of left and right channels)
    public var amplitude: Float {
        return amp.reduce(0, +) / 2
    }

    /// Detected frequency of left channel
    public var leftPitch: Float {
        return pitch[0]
    }

    /// Detected frequency of right channel
    public var rightPitch: Float {
        return pitch[1]
    }
    
    func convertBufferToFloats(trackNumber: Int) -> AVAudioPCMBuffer {
        let fileURL = FilesManager.getFileURL(trackNumber: trackNumber)
        
        guard FilesManager.checkIfFileExists(fileURL: fileURL) else {
            return AVAudioPCMBuffer()
        }
        
        let audioFile = try! AVAudioFile(forReading: fileURL)
        
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false) else { return AVAudioPCMBuffer() }
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(audioFile.length))
        try! audioFile.read(into: audioBuffer!)
//        let floatArray = Array(UnsafeBufferPointer(start: audioBuffer?.floatChannelData![0], count:Int(audioBuffer!.frameLength)))
//
//        return (signal: floatArray, rate: audioFile.fileFormat.sampleRate, frameCount: Int(audioFile.length))
        return audioBuffer ?? AVAudioPCMBuffer()
        
    }
    
    func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        guard let floatData = buffer.floatChannelData else { return }
        let channelCount = Int(buffer.format.channelCount)
        let length = UInt(buffer.frameLength)
        while self.trackers.count < channelCount {
            self.trackers.append(akPitchTrackerCreate(UInt32(48000), 4_096, 20))
        }

        while self.amp.count < channelCount {
            self.amp.append(0)
            self.pitch.append(0)
        }

        // n is the channel
        for n in 0 ..< channelCount {
            let data = floatData[n]

            akPitchTrackerAnalyze(self.trackers[n], data, UInt32(length))

            var a: Float = 0
            var f: Float = 0
            akPitchTrackerGetResults(self.trackers[n], &a, &f)
            self.amp[n] = a
            self.pitch[n] = f
        }
    }
    
    func smoothSignal(){
        
    }
}
