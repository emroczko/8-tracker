//
//  MidiConverter.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 28/11/2021.
//

import Foundation
import AVKit
import CSoundpipeAudioKit
import AudioKit
import Accelerate

struct SoundInfo{
    var pitch: Int
    var amplitude: AUValue
}

class MidiConverter {
    
    private var pitch: [Float] = [0, 0]
    private var amp: [Float] = [0, 0]
    private var trackers: [PitchTrackerRef] = []
    private var soundArray: [SoundInfo] = []
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteMidiNumbers = [24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36]
    private var midiNotes: [MIDINoteData] = []
    var midiNotesCompleted: [MIDINoteData] = []
    var tempo: Double = 120
    let sampleLength: Int = 4096

    public var amplitude: Float {
        return amp.reduce(0, +) / 2
    }
    
    func convertAudioToMidi(trackNumber: Int, tempo: Double) -> [MIDINoteData]{
        
        self.tempo = tempo
        divideIntoBuffers(trackNumber: trackNumber)
        smoothNotes()
        createMidiMessages()
        lengthenNotes()
    
        return midiNotesCompleted
    }
    
    private func divideIntoBuffers(trackNumber: Int){
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
            findPitchAndAmplitude(buffer: audioBuffer!)
        }
    }
    
    private func findPitchAndAmplitude(buffer: AVAudioPCMBuffer) {
                
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
    
    private func processPitch(pitch: AUValue) -> Int {
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
        let octave = Int(log2f(pitch / frequency)) - 1
        
        return noteMidiNumbers[index] + 12 * octave
    }
    
    private func createMidiMessages(){
        var currentPosition: Int = 0
        for sound in soundArray {
            let noteNumber = sound.amplitude > 0.3 ? sound.pitch : 0
            let velocity = sound.amplitude > 0.35 ? sound.amplitude : 0
            let duration = Duration(samples: sampleLength, sampleRate: 48000, tempo: BPM(tempo))
            let position = Duration(samples: 0 + currentPosition, sampleRate: 48000, tempo: BPM(tempo))
            
            midiNotes.append(MIDINoteData(noteNumber: MIDINoteNumber(noteNumber), velocity: MIDIVelocity(velocity), channel: 0, duration: duration, position: position))
            
            currentPosition += sampleLength
        }
    }
    
    private func smoothNotes(){
        
        for i in 2 ... soundArray.count {
            if(i + 2 < soundArray.count){
                if(soundArray[i-1].pitch == soundArray[i+1].pitch){
                    if(soundArray[i].pitch != soundArray[i-1].pitch){
                        soundArray[i].pitch = soundArray[i-1].pitch
                    }
                }
            }
        }
        
        for i in 2 ... soundArray.count {
            if(i + 2 < soundArray.count){
                if ((soundArray[i-2].pitch == soundArray[i-1].pitch) && (soundArray[i+1].pitch == soundArray[i+2].pitch)){
                    if(soundArray[i-1].pitch == soundArray[i+1].pitch){
                        if(soundArray[i].pitch != soundArray[i-1].pitch){
                            soundArray[i].pitch = soundArray[i-1].pitch
                        }
                    }
                }
            }
        }
    }
    
    func lengthenNotes(){
        var noteStartingPosition: Duration = Duration(samples: 0, sampleRate: 48000, tempo: BPM(tempo))
        var noteLength: Duration = Duration(samples: sampleLength, sampleRate: 48000, tempo: BPM(tempo))
        for i in 1 ... midiNotes.count - 1 {
            if (midiNotes[i].noteNumber == midiNotes[i-1].noteNumber){
                noteLength += Duration(samples: sampleLength, sampleRate: 48000, tempo: BPM(tempo))
            }
            else{
                midiNotesCompleted.append(MIDINoteData(noteNumber: MIDINoteNumber(midiNotes[i-1].noteNumber), velocity: MIDIVelocity(midiNotes[i-1].velocity), channel: 0, duration: noteLength, position: noteStartingPosition))
                noteStartingPosition = midiNotes[i].position
                noteLength = Duration(samples: sampleLength, sampleRate: 48000, tempo: BPM(tempo))
            }
            
            if (i == midiNotes.count - 1 ){
                midiNotesCompleted.append(MIDINoteData(noteNumber: MIDINoteNumber(midiNotes[i].noteNumber), velocity: MIDIVelocity(midiNotes[i].velocity), channel: 0, duration: noteLength, position: noteStartingPosition))
            }
        }
        
        midiNotesCompleted.append(MIDINoteData(noteNumber: MIDINoteNumber(127), velocity: MIDIVelocity(0), channel: 0, duration: Duration(samples: 0), position: noteStartingPosition + noteLength))
    }
}
