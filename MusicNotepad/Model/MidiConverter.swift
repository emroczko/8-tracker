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

struct SoundInfo{
    var pitch: Double
    var amplitude: AUValue
}

class MidiConverter {
    
    static var sharedInstance = MidiConverter()
    
    private var pitch: [Float] = [0, 0]
    private var amp: [Float] = [0, 0]
    private var trackers: [PitchTrackerRef] = []
    private var buffers: [AVAudioPCMBuffer] = []
    private var soundArray: [SoundInfo] = []
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

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
    
    func convertBufferToFloats(trackNumber: Int){
        let fileURL = FilesManager.getFileURL(trackNumber: trackNumber)
        
        guard FilesManager.checkIfFileExists(fileURL: fileURL) else { return }
        
        let audioFile = try! AVAudioFile(forReading: fileURL)
        
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate, channels: audioFile.fileFormat.channelCount, interleaved: false) else { return }
        
        var currentPosition: Int = 0
        
        while currentPosition < audioFile.length {
            audioFile.framePosition = AVAudioFramePosition(currentPosition)
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(4096))
            try! audioFile.read(into: audioBuffer!)
            currentPosition += 4096
            buffers.append(audioBuffer!)
        }
        
        print("audiofile length: \(audioFile.length)")
        print("buffers length: \(buffers.count)")
        
        processBuffers()
    }
    
    func processBuffers(){
        for buffer in buffers {
            doHandleTapBlock(buffer: buffer)
        }
    }
    
    func doHandleTapBlock(buffer: AVAudioPCMBuffer) {
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
        
        self.soundArray.append(SoundInfo(pitch: processPitch(pitch: pitch[0]), amplitude: self.amp[0]))
        
    }
    
    func processPitch(pitch: AUValue) -> Double{
        var frequency = pitch
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }

        var minDistance: Float = 10_000.0
        var index = 0

        for possibleIndex in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
            if distance < minDistance {
                index = possibleIndex
                minDistance = distance
            }
        }
        let octave = Int(log2f(pitch / frequency))
        print("\(noteNamesWithSharps[index])\(octave)")
        
        return noteFrequencies[index]
    }
    
    func createMidiMessages(){
        
    }
    
}
