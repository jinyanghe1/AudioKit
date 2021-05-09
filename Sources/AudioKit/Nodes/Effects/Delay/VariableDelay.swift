// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import CAudioKit

/// A delay line with cubic interpolation.
public class VariableDelay: NodeBase {

    let input: Node
    override public var connections: [Node] { [input] }

    // MARK: - Parameters

    /// Specification details for time
    public static let timeDef = NodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: akGetParameterAddress("VariableDelayParameterTime"),
        defaultValue: 0,
        range: 0 ... 10,
        unit: .seconds)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter(timeDef) public var time: AUValue

    /// Specification details for feedback
    public static let feedbackDef = NodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("VariableDelayParameterFeedback"),
        defaultValue: 0,
        range: 0 ... 1,
        unit: .generic)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter(feedbackDef) public var feedback: AUValue

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: Node,
        time: AUValue = timeDef.defaultValue,
        feedback: AUValue = feedbackDef.defaultValue,
        maximumTime: AUValue = 5
        ) {
        self.input = input
        super.init(avAudioNode: AVAudioNode())

        avAudioNode = instantiate(effect: "vdla")

        guard let audioUnit = avAudioNode.auAudioUnit as? AudioUnitBase else {
            fatalError("Couldn't create audio unit")
        }
        akVariableDelaySetMaximumTime(audioUnit.dsp, maximumTime)

        self.time = time
        self.feedback = feedback
   }
}
