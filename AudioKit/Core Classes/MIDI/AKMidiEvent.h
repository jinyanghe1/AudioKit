//
//  AKMidiEvent.h
//  AudioKit
//
//  Created by Stéphane Peter on 7/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notification names broadcasted for MIDI events being received from the inputs.
extern NSString * __nonnull const AKMidiNoteOnNotification;
extern NSString * __nonnull const AKMidiNoteOffNotification;
extern NSString * __nonnull const AKMidiPolyphonicAftertouchNotification;
extern NSString * __nonnull const AKMidiProgramChangeNotification;
extern NSString * __nonnull const AKMidiAftertouchNotification;
extern NSString * __nonnull const AKMidiPitchWheelNotification;
extern NSString * __nonnull const AKMidiControllerNotification;
extern NSString * __nonnull const AKMidiModulationNotification;
extern NSString * __nonnull const AKMidiPortamentoNotification;
extern NSString * __nonnull const AKMidiVolumeNotification;
extern NSString * __nonnull const AKMidiBalanceNotification;
extern NSString * __nonnull const AKMidiPanNotification;
extern NSString * __nonnull const AKMidiExpressionNotification;
extern NSString * __nonnull const AKMidiControlNotification;

/// MIDI note on/off, control and system exclusive constants

// These are the top 4 bits of the MIDI command, for commands that take a channel number in the low 4 bits
typedef NS_ENUM(UInt8, AKMidiStatus)
{
    AKMidiStatusNoteOff = 8,
    AKMidiStatusNoteOn = 9,
    AKMidiStatusPolyphonicAftertouch = 10,
    AKMidiStatusControllerChange = 11,
    AKMidiStatusProgramChange = 12,
    AKMidiStatusChannelAftertouch = 13,
    AKMidiStatusPitchWheel = 14,
    AKMidiStatusSystemCommand = 15
};

// System commands (8 bits - 0xFx) that do not require a channel number
typedef NS_ENUM(UInt8, AKMidiSystemCommand)
{
    AKMidiCommandNone = 0,
    AKMidiCommandSysex = 240,
    AKMidiCommandSongPosition = 242,
    AKMidiCommandSongSelect = 243,
    AKMidiCommandTuneRequest = 246,
    AKMidiCommandSysexEnd = 247,
    AKMidiCommandClock = 248,
    AKMidiCommandStart = 250,
    AKMidiCommandContinue = 251,
    AKMidiCommandStop = 252,
    AKMidiCommandActiveSensing = 254,
    AKMidiCommandSysReset = 255
};

// Value of byte 2 in conjunction with AKMidiStatusControllerChange
typedef NS_ENUM(UInt8, AKMidiControl)
{
    AKMidiControlCC0 = 0,
    AKMidiControlModulationWheel = 1,
    AKMidiControlBreathControl = 2,
    AKMidiControlCC3 = 3,
    AKMidiControlFootControl = 4,
    AKMidiControlPortamento = 5,
    AKMidiControlDataEntry = 6,
    AKMidiControlMainVolume = 7,
    AKMidiControlBalance = 8,
    AKMidiControlCC9 = 9,
    AKMidiControlPan = 10,
    AKMidiControlExpression = 11,
    AKMidiControlCC12 = 12,
    AKMidiControlCC13 = 13,
    AKMidiControlCC14 = 14,
    AKMidiControlCC15 = 15,
    AKMidiControlCC16 = 16,
    AKMidiControlCC17 = 17,
    AKMidiControlCC18 = 18,
    AKMidiControlCC19 = 19,
    AKMidiControlCC20 = 20,
    AKMidiControlCC21 = 21,
    AKMidiControlCC22 = 22,
    AKMidiControlCC23 = 23,
    AKMidiControlCC24 = 24,
    AKMidiControlCC25 = 25,
    AKMidiControlCC26 = 26,
    AKMidiControlCC27 = 27,
    AKMidiControlCC28 = 28,
    AKMidiControlCC29 = 29,
    AKMidiControlCC30 = 30,
    AKMidiControlCC31 = 31,
    
    AKMidiControlLSB = 32, // Combine with above constants to get the LSB

    AKMidiControlDamperOnOff = 64,
    AKMidiControlPortamentoOnOff = 65,
    AKMidiControlSustenutoOnOff = 66,
    AKMidiControlSoftPedalOnOff = 67,
    
    AKMidiControlDataEntryPlus = 96,
    AKMidiControlDataEntryMinus = 97,
    
    AKMidiControlLocalControlOnOff = 122,
    AKMidiControlAllNotesOff = 123,
};

// Forward declaration from CoreMidi
typedef struct MIDIPacket MIDIPacket;

NS_ASSUME_NONNULL_BEGIN
@interface AKMidiEvent : NSObject

// Up to 3 bytes of data in a single MIDI event, status and channel share the first byte.
/// The MIDI status control, might be AKMidiStatusSystemCommand
@property (readonly,nonatomic) AKMidiStatus status;
/// The MIDI system command this event is for, or None
@property (readonly,nonatomic) AKMidiSystemCommand command;

/// Channel number (1..16), or 0 if this MIDI event doesn't have a channel number.
@property (readonly,nonatomic) UInt8 channel;
/// Additional 7-bits of data (0..127)
@property (readonly,nonatomic) UInt8 data1, data2;
/// Composite using data1 as LSB, data2 as MSB (14 bits of data)
@property (readonly,nonatomic) UInt16 data;

/// The length in bytes for this MIDI message (1 to 3 bytes)
@property (readonly,nonatomic) UInt8 length;
/// The MIDI message data bytes as NSData.
@property (readonly,nonatomic) NSData *bytes;

- (instancetype)initWithStatus:(AKMidiStatus)status channel:(UInt8)channel data1:(UInt8)d1 data2:(UInt8)d2;
- (instancetype)initWithSystemCommand:(AKMidiSystemCommand)command data1:(UInt8)d1 data2:(UInt8)d2;
/// Create from a CoreMIDI packet.
- (instancetype)initWithMIDIPacket:(MIDIPacket *)packet;
/// Create from a NSData object.
- (instancetype)initWithData:(NSData *)data;

/// Convenience constructor
+ (instancetype)midiEventFromPacket:(MIDIPacket *)packet;

/// Copy the bytes from the MIDI message to a provided buffer.
- (void)copyBytes:(void *)ptr;

/// Post a notification describing the MIDI event. Returns YES if a notification was actually posted.
- (BOOL)postNotification;

@end
NS_ASSUME_NONNULL_END

