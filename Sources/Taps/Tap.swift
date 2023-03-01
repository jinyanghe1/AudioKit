// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Audio
import AudioUnit
import AVFoundation
import Foundation
import Utilities

/// Node which provides a callback that "taps" the audio data from the stream.
public class Tap: Node {
    public let connections: [Node]

    public let au: AUAudioUnit

    private let tapAU: TapAudioUnit

    /// Create a Tap.
    ///
    /// - Parameters:
    ///   - input: Input to monitor.
    ///   - tapBlock: Called with a stereo pair of channels. Note that this doesn't need to be realtime safe. Called on the main thread.
    public init(_ input: Node, bufferSize: Int = 1024, tapBlock: @escaping ([Float], [Float]) -> Void) {
        let componentDescription = AudioComponentDescription(effect: "tapn")

        AUAudioUnit.registerSubclass(TapAudioUnit.self,
                                     as: componentDescription,
                                     name: "Tap AU",
                                     version: .max)
        au = instantiateAU(componentDescription: componentDescription)
        tapAU = au as! TapAudioUnit
        tapAU.tapBlock = tapBlock
        tapAU.bufferSize = bufferSize
        connections = [input]
    }
}

class TapAudioUnit: AUAudioUnit {
    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    let ringBuffer = RingBuffer<Float>(capacity: 4096)

    var tapBlock: ([Float], [Float]) -> Void = { _, _ in }
    var semaphore = DispatchSemaphore(value: 0)
    var run = true
    var bufferSize = 1024

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws
    {
        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: format)])

        let thread = Thread {
            var left: [Float] = []
            var right: [Float] = []

            while true {
                self.semaphore.wait()

                if !self.run {
                    return
                }

                var i = 0
                self.ringBuffer.popAll { sample in
                    if i.isMultiple(of: 2) {
                        left.append(sample)
                    } else {
                        right.append(sample)
                    }
                    i += 1
                }

                while left.count > self.bufferSize {
                    let leftPrefix = Array(left.prefix(self.bufferSize))
                    let rightPrefix = Array(right.prefix(self.bufferSize))

                    left = Array(left.dropFirst(self.bufferSize))
                    right = Array(right.dropFirst(self.bufferSize))

                    DispatchQueue.main.async {
                        self.tapBlock(leftPrefix, rightPrefix)
                    }
                }
            }
        }
        thread.start()
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override var internalRenderBlock: AUInternalRenderBlock {

        let ringBuffer = self.ringBuffer
        let semaphore = self.semaphore

        return { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            // Better be stereo.
            assert(ablPointer.count == 2)

            // Check that buffers are the correct size.
            if ablPointer[0].frameCapacity < frameCount {
                print("output buffer 1 too small: \(ablPointer[0].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            if ablPointer[1].frameCapacity < frameCount {
                print("output buffer 2 too small: \(ablPointer[1].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            var inputFlags: AudioUnitRenderActionFlags = []
            _ = inputBlock?(&inputFlags, timeStamp, frameCount, 0, outputBufferList)

            let outBufL = UnsafeBufferPointer<Float>(ablPointer[0])
            let outBufR = UnsafeBufferPointer<Float>(ablPointer[1])

            // We are assuming there is enough room in the ring buffer
            // for the all the samples. If not there's nothing we can do.
            _ = ringBuffer.push(interleaving: outBufL, and: outBufR)
            semaphore.signal()

            return noErr
        }
    }

}
