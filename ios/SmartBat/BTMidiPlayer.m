//
//  BTMidiPlayer.m
//  SmartBat
//
//  Created by poppy on 13-7-11.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMidiPlayer.h"

@implementation BTMidiPlayer

@synthesize loop = _loop, BPM=_BPM, startTime, timeElapsed = _timeElapsed, pulsesElapsed = _pulsesElapsed, URL=_URL, originalBPM, PPQN=_PPQN;

-(BTMidiPlayer *)init
{
    self = [super init];
    
    
    _candidateSequence = [[BTMidiSequence alloc]init];
    _tempSequence = [[BTMidiSequence alloc]init];
    
    _eventsToDelete = [NSMutableArray new];
    
    _midiClock = [[BTMidiClock alloc]init];
    _midiClock.midiClockDelegate = self;
    
    _pulsesElapsed = -1;
    _timeElapsed = 0;
    
    _loop = YES;
    
    _BPM = 80;
    
    return self;
}

//预加载文件。不会干扰当前播放器状态。若播放器正在播放，需要调用play系列方法才能播放新的file。
-(void)loadFile:(NSString *)filename withExtension:(NSString *)extension ignoreOriginalBPM:(Boolean) isIgnoreOriginalBPM
{

    NSURL *midiFileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    
    _URL = midiFileURL;
    _isIgnoreOriginalBPM = isIgnoreOriginalBPM;
    
    NSLog(@"midi file url: %@",midiFileURL);
    
    // Create a new music sequence - this will store all the
    // data collected from the midi file
    MusicSequence s;
    
    // Initialise the music sequence - CoreMidi is procedural
    // but it tries to use some techniques from object orientated
    // programming. New music sequence is like initialising the
    // MusicSequence variable
    NewMusicSequence(&s);
    

    // Load the MIDI file into the MusicSequence variable
    MusicSequenceFileLoad(s, (__bridge CFURLRef)midiFileURL, 0, 0);
    
    // You can use CAShow here to print a text version of the whole
    // midi file into the consol for debugging
    CAShow(s);
    
    // The number of tracks
    UInt32 tracks;
    
    // Populate the track count
    MusicSequenceGetTrackCount(s, &tracks);
    
    // Create a track
    MusicTrack track = NULL;
    
    // The tempo track is a track which only contains tempo
    // information. It contains no notes
    MusicTrack tempoTrack;
    
    // Retrieve the tempo track from the sequence
    MusicSequenceGetTempoTrack(s, &tempoTrack);
    
    // Get the pulses per quarter note from the tempo track
    SInt16 resolution;
    UInt32 length;
    
    // The pulses per quarter note is stored as a property in the
    // track. This is accessed using the get property method
    MusicTrackGetProperty(tempoTrack, kSequenceTrackProperty_TimeResolution, &resolution, &length);
    
    _PPQN = resolution;

    // Print the PPNQ for logging purposes
    NSLog(@"PPQN: %i", _PPQN);
    
    // Process the note sequences
    for (NSInteger i=0; i<tracks; i++) {
        // Set the track variable to the current track number
        MusicSequenceGetIndTrack(s, i, &track);
        
        // Add the events from the track to the sequence object
        [self processTrack:track withTrackNumber:i withSequence: _candidateSequence];
    }
    
    // Process the events from the tempo track
    [self processTrack:tempoTrack withTrackNumber:99 withSequence: _candidateSequence];
    
    // Make sure the sequence is ordered by note start time ready to be played
    [_candidateSequence sortSequenceByStartTime];
    
    
    
    
    
    // Create a new audio manager this will vocalize the midi messages
    _audioManager = [BTMidiAudioManager newAudioManager];
    
    // Load the default general midi instruments from the midi file
    [_audioManager configureForGeneralMidi:@"fluid_gm" withSequence:_candidateSequence];
    
    // Enable percussion
    [_audioManager enablePercussion:@"fluid_gm" withPatch:0 withVolume:1];
    
    // Add a silent default
    [_audioManager addDefaultVoice:@"fluid_gm" withPatch:0 withVolume:1];
    
    // Start the audio manager. After the audio manager has started you can't add any more
    // voices
    [_audioManager startAudioGraph];
    
}

//在第timeElapsed时间开始播放，以startTime为起点
-(void)playAtTime:(double)timeElapsed
{
    _tempSequence.sequence = [_candidateSequence copiedSequence];

    
    [ _midiClock startLoopWithDuration:60.0/(self.BPM * self.PPQN)];
}

//在第pulsesElapsed的位置开始播放，以startTime为起点
-(void)playAtPulse:(int)pulsesElapsed
{
    
}

//暂停播放
-(void) pause
{
    
}

//停止播放，同时复位
-(void) stop
{
    
}


-(void)parseMidiFile
{
    
}


-(void) update: (NSInteger) timeInPulses{
    
    
    
    // Other pointers we setup to improve efficiency
    BTMidiEvent * midiEvent;
    id objectToDelete;
    
    // Loop over sequence and work out if the note should be played
    for(int j=0; j<[_tempSequence eventCount]; j++) {
        
        // Get a pointer to the current event
        midiEvent = [[_tempSequence getSequence] objectAtIndex:j];
        
        // If the time is greater than the current time then skip the note
        // and add one to the relaxation counter
        if([midiEvent getStartTime] > timeInPulses) {
            continue;
        }

        [_eventsToDelete addObject:midiEvent];
        
        if(midiEvent.eventType == Note) {
            BTMidiNote * note = (BTMidiNote *) midiEvent;
            
            //todo: delegate
            NSLog(@"note: %d, timeInPulses: %d, startTime: %ld, d: %d. e: %d",note.note, timeInPulses,(long)[note getStartTime], [note getDuration], note.endTime );
            
            [_audioManager playNote:note];
            
            
        }
        else if(midiEvent.eventType == Tempo ) {
            
        }
    }

    for(int j=0; j<[_eventsToDelete count]; j++) {
        objectToDelete = [_eventsToDelete objectAtIndex:j];
        [[_tempSequence getSequence] removeObject:objectToDelete];
    }
    
    [_eventsToDelete removeAllObjects];
    
    if(self.loop)
    {
        if(![_tempSequence eventCount] && (timeInPulses+1) % (_PPQN * 4) == 0)
        {
            _pulsesElapsed = -1;
            _tempSequence.sequence = [_candidateSequence copiedSequence];
            
        }
        
    }
    
    [_audioManager update:timeInPulses];
    
}


- (void) processTrack: (MusicTrack) track withTrackNumber: (NSInteger) trackNum withSequence: (BTMidiSequence * ) midiSequence {

    // Setup iterator - the iterator helps us loop over the events in the track
    MusicEventIterator iterator = NULL;
    NewMusicEventIterator(track, &iterator);
    
    // Values to be retrieved from event
    // Start time in quarter notes
    MusicTimeStamp timestamp = 0;
    // The MIDI message type
    MusicEventType eventType = 0;
    
    // The data contained in the message
    const void *eventData = NULL;
    UInt32 eventDataSize = 0;
    
    // Prepair variables for loop
    Boolean hasNext = YES;
    
    // Some variables to contain events which we'll use many times
    MIDINoteMessage * midiNoteMessage;
    MIDIMetaEvent * midiMetaEvent;
    
    while (hasNext) {
        
        // See if there are any more events
        MusicEventIteratorHasNextEvent(iterator, &hasNext);
        
        // Copy the event data into the variables we prepaired earlier
        MusicEventIteratorGetEventInfo(iterator, &timestamp, &eventType, &eventData, &eventDataSize);
        
        
        
        
        // Process Midi Note messages
        if(eventType==kMusicEventType_MIDINoteMessage) {
            // Cast the midi event data as a midi note message
            midiNoteMessage = (MIDINoteMessage*) eventData;
            
            // Create a new note event object
            BTMidiNote * midiNote = [BTMidiNote new];
            
            // Add the timestamp so we know when to play the note
            // Convert the start time and duration into clock pulses by multiplying by PPQN
            [midiNote setStartTime: timestamp * _PPQN];
            [midiNote setDuration:midiNoteMessage->duration * _PPQN];
            
            // Set the note velocity - how loud the note is played
            midiNote.velocity = midiNoteMessage->velocity;
            
            // The channel the note is played on - this defines the instrument
            midiNote.channel = midiNoteMessage->channel;
            midiNote.releaseVelocity = midiNoteMessage->releaseVelocity;
            
            midiNote.track = trackNum;
            
            // Add the midi message note - a number 0 - 127
            midiNote.note = midiNoteMessage->note;
            
            // Here I'm limiting the number of channels to be used to
            // 10. There seems to be a bug in CoreAudio which causes
            // audio distortions when more than 10 Midi samplers are
            // used. Remove this at your own risk!
            if( midiNote.channel < 10)
                [midiSequence addEvent: midiNote];
            
            NSLog(@"midiNote: %ld", (long)[midiNote getStartTime]);
            
        }
        
        // Channel messages - control change / program change
        if(eventType == kMusicEventType_MIDIChannelMessage) {
            // Cast the event data as a channel message
            MIDIChannelMessage * channelMessage = (MIDIChannelMessage *) eventData;
            
            // Create a new channel event object
            BTMidiChannelEvent * channelEvent = [BTMidiChannelEvent new];
            
            // Set the start time in pulses
            [channelEvent setStartTime:timestamp * _PPQN];
            
            // set the channel and data - note the use of bitwise
            // operations to extract the channel
            channelEvent.channel = channelMessage->status & 0x0f;
            
            // For more information see BChannelEvent.h
            channelEvent.data1 = channelMessage->data1;
            channelEvent.data2 = channelMessage->data2;
            
            // Control Change - Used to set the value of a particular controller
            // Note the use of bitwise operations to extract the message type
            if(channelMessage->status >> 4 == 11) {
                channelEvent.type = Controller;
            }
            
            // Program Change - Used to assign an instrument to a particular
            // channel
            if(channelMessage->status >> 4 == 12) {
                channelEvent.type = Program;
            }
            
            // Add the events to the sequence
            [midiSequence addEvent:channelEvent];
            
        }
        
        // The extended tempo event happens on the tempo track
        // It contains a beats per minute value
        if(eventType == kMusicEventType_ExtendedTempo) {
            ExtendedTempoEvent * te = (ExtendedTempoEvent *) eventData;
            
            // Create a new tempo event
            BTMidiTempoEvent * tempoEvent = [BTMidiTempoEvent new];
            
            // Set the start time in pulses
            [tempoEvent setStartTime:timestamp * _PPQN];
            // Set the type to tempo
            tempoEvent.type = BTempo;
            // Set the bpm value
            tempoEvent.BPM = te->bpm;
            
            // Add the event to the sequence
            [midiSequence addEvent:tempoEvent];
        }
        
        // Process Meta events
        
        if(eventType == kMusicEventType_Meta) {
            
            midiMetaEvent = (MIDIMetaEvent*) eventData;
            
            // Time signature information
            if(midiMetaEvent->metaEventType == 0x58) {
                
                // Create a new tempo event
                BTMidiTempoEvent * tempoEvent = [BTMidiTempoEvent new];
                
                // Set the start time in pulses
                [tempoEvent setStartTime: timestamp * _PPQN];
                
                // Set the type to time signature
                tempoEvent.type = BTimeSignature;
                
                // Set the numerator - beats per bar
                tempoEvent.timeSignatureNumerator = midiMetaEvent->data[0];
                // Which note value represents one beat 4 -> quarter note, 2 implies half note
                tempoEvent.timeSignatureDenominator = 2 ^ midiMetaEvent->data[1];
                // Metronome ticks per quarter a value of 24 implies one tick per quarter note
                tempoEvent.ticksPerQtr = midiMetaEvent->data[2];
                // Used to vary rate of play of piece
                tempoEvent._32ndNotesPerBeat = midiMetaEvent->data[3];
                
                // Add event to the sequence
                [midiSequence addEvent:tempoEvent];
                
            }

        }
        // Update the iterator to the next event
        MusicEventIteratorNextEvent(iterator);
    }
}


+(BTMidiPlayer *)sharedPlayer
{
    static BTMidiPlayer *sharedPlayer = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedPlayer = [[self alloc] init];
    });
    return sharedPlayer;
}


-(void)onMidiClockTickHandler:(double) time
{
    _pulsesElapsed++;
    
    [self update:_pulsesElapsed];
    
//    NSLog(@"onMidiClockTickHandler: %f", time);
    
    
}

@end
