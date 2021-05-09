// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import CAudioKit

/// 8 FDN stereo zitareverb algorithm, imported from Faust.
public class ZitaReverb: NodeBase {

    let input: Node
    override public var connections: [Node] { [input] }

    // MARK: - Parameters

    /// Specification details for predelay
    public static let predelayDef = NodeParameterDef(
        identifier: "predelay",
        name: "Delay in ms before reverberation begins.",
        address: akGetParameterAddress("ZitaReverbParameterPredelay"),
        defaultValue: 60.0,
        range: 0.0 ... 200.0,
        unit: .generic)

    /// Delay in ms before reverberation begins.
    @Parameter(predelayDef) public var predelay: AUValue

    /// Specification details for crossoverFrequency
    public static let crossoverFrequencyDef = NodeParameterDef(
        identifier: "crossoverFrequency",
        name: "Crossover frequency separating low and middle frequencies (Hz).",
        address: akGetParameterAddress("ZitaReverbParameterCrossoverFrequency"),
        defaultValue: 200.0,
        range: 10.0 ... 1_000.0,
        unit: .hertz)

    /// Crossover frequency separating low and middle frequencies (Hz).
    @Parameter(crossoverFrequencyDef) public var crossoverFrequency: AUValue

    /// Specification details for lowReleaseTime
    public static let lowReleaseTimeDef = NodeParameterDef(
        identifier: "lowReleaseTime",
        name: "Time (in seconds) to decay 60db in low-frequency band.",
        address: akGetParameterAddress("ZitaReverbParameterLowReleaseTime"),
        defaultValue: 3.0,
        range: 0.0 ... 10.0,
        unit: .seconds)

    /// Time (in seconds) to decay 60db in low-frequency band.
    @Parameter(lowReleaseTimeDef) public var lowReleaseTime: AUValue

    /// Specification details for midReleaseTime
    public static let midReleaseTimeDef = NodeParameterDef(
        identifier: "midReleaseTime",
        name: "Time (in seconds) to decay 60db in mid-frequency band.",
        address: akGetParameterAddress("ZitaReverbParameterMidReleaseTime"),
        defaultValue: 2.0,
        range: 0.0 ... 10.0,
        unit: .seconds)

    /// Time (in seconds) to decay 60db in mid-frequency band.
    @Parameter(midReleaseTimeDef) public var midReleaseTime: AUValue

    /// Specification details for dampingFrequency
    public static let dampingFrequencyDef = NodeParameterDef(
        identifier: "dampingFrequency",
        name: "Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.",
        address: akGetParameterAddress("ZitaReverbParameterDampingFrequency"),
        defaultValue: 6_000.0,
        range: 10.0 ... 22_050.0,
        unit: .hertz)

    /// Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    @Parameter(dampingFrequencyDef) public var dampingFrequency: AUValue

    /// Specification details for equalizerFrequency1
    public static let equalizerFrequency1Def = NodeParameterDef(
        identifier: "equalizerFrequency1",
        name: "Center frequency of second-order Regalia Mitra peaking equalizer section 1.",
        address: akGetParameterAddress("ZitaReverbParameterEqualizerFrequency1"),
        defaultValue: 315.0,
        range: 10.0 ... 1_000.0,
        unit: .hertz)

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    @Parameter(equalizerFrequency1Def) public var equalizerFrequency1: AUValue

    /// Specification details for equalizerLevel1
    public static let equalizerLevel1Def = NodeParameterDef(
        identifier: "equalizerLevel1",
        name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1",
        address: akGetParameterAddress("ZitaReverbParameterEqualizerLevel1"),
        defaultValue: 0.0,
        range: -100.0 ... 10.0,
        unit: .generic)

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    @Parameter(equalizerLevel1Def) public var equalizerLevel1: AUValue

    /// Specification details for equalizerFrequency2
    public static let equalizerFrequency2Def = NodeParameterDef(
        identifier: "equalizerFrequency2",
        name: "Center frequency of second-order Regalia Mitra peaking equalizer section 2.",
        address: akGetParameterAddress("ZitaReverbParameterEqualizerFrequency2"),
        defaultValue: 1_500.0,
        range: 10.0 ... 22_050.0,
        unit: .hertz)

    /// Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    @Parameter(equalizerFrequency2Def) public var equalizerFrequency2: AUValue

    /// Specification details for equalizerLevel2
    public static let equalizerLevel2Def = NodeParameterDef(
        identifier: "equalizerLevel2",
        name: "Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2",
        address: akGetParameterAddress("ZitaReverbParameterEqualizerLevel2"),
        defaultValue: 0.0,
        range: -100.0 ... 10.0,
        unit: .generic)

    /// Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    @Parameter(equalizerLevel2Def) public var equalizerLevel2: AUValue

    /// Specification details for dryWetMix
    public static let dryWetMixDef = NodeParameterDef(
        identifier: "dryWetMix",
        name: "0 = all dry, 1 = all wet",
        address: akGetParameterAddress("ZitaReverbParameterDryWetMix"),
        defaultValue: 1.0,
        range: 0.0 ... 1.0,
        unit: .percent)

    /// 0 = all dry, 1 = all wet
    @Parameter(dryWetMixDef) public var dryWetMix: AUValue

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - predelay: Delay in ms before reverberation begins.
    ///   - crossoverFrequency: Crossover frequency separating low and middle frequencies (Hz).
    ///   - lowReleaseTime: Time (in seconds) to decay 60db in low-frequency band.
    ///   - midReleaseTime: Time (in seconds) to decay 60db in mid-frequency band.
    ///   - dampingFrequency: Frequency (Hz) at which the high-frequency T60 is half the middle-band's T60.
    ///   - equalizerFrequency1: Center frequency of second-order Regalia Mitra peaking equalizer section 1.
    ///   - equalizerLevel1: Peak level in dB of second-order Regalia-Mitra peaking equalizer section 1
    ///   - equalizerFrequency2: Center frequency of second-order Regalia Mitra peaking equalizer section 2.
    ///   - equalizerLevel2: Peak level in dB of second-order Regalia-Mitra peaking equalizer section 2
    ///   - dryWetMix: 0 = all dry, 1 = all wet
    ///
    public init(
        _ input: Node,
        predelay: AUValue = predelayDef.defaultValue,
        crossoverFrequency: AUValue = crossoverFrequencyDef.defaultValue,
        lowReleaseTime: AUValue = lowReleaseTimeDef.defaultValue,
        midReleaseTime: AUValue = midReleaseTimeDef.defaultValue,
        dampingFrequency: AUValue = dampingFrequencyDef.defaultValue,
        equalizerFrequency1: AUValue = equalizerFrequency1Def.defaultValue,
        equalizerLevel1: AUValue = equalizerLevel1Def.defaultValue,
        equalizerFrequency2: AUValue = equalizerFrequency2Def.defaultValue,
        equalizerLevel2: AUValue = equalizerLevel2Def.defaultValue,
        dryWetMix: AUValue = dryWetMixDef.defaultValue
        ) {
        self.input = input
        super.init(avAudioNode: AVAudioNode())

        avAudioNode = instantiate(effect: "zita")

        self.predelay = predelay
        self.crossoverFrequency = crossoverFrequency
        self.lowReleaseTime = lowReleaseTime
        self.midReleaseTime = midReleaseTime
        self.dampingFrequency = dampingFrequency
        self.equalizerFrequency1 = equalizerFrequency1
        self.equalizerLevel1 = equalizerLevel1
        self.equalizerFrequency2 = equalizerFrequency2
        self.equalizerLevel2 = equalizerLevel2
        self.dryWetMix = dryWetMix
   }
}
