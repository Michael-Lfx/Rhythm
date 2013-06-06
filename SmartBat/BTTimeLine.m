//
//  BTTimeLine.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeLine.h"

#define DEFAULT_INTERVAL 0.01

@implementation BTTimeLine

@synthesize interval;

-(id)init
{
    self = [super init];
    _isStop = true;
    return self;
}

-(void) setupClock {
    _startTime = [NSDate date];
    _previousTime = 0;
}


-(void) loop:(id) info
{
    
    // Loop until the program terminates
    while (!_isStop) {
        
        // Update the midi clock every loop
        
        [NSThread setThreadPriority:1.0];
        
        [self performSelectorOnMainThread:@selector(invokeDelegate:) withObject:nil waitUntilDone:YES];

        [NSThread sleepForTimeInterval: DEFAULT_INTERVAL];
        
        // Only check for events if the required number of ticks
        // has elapsed - determined by _midiClock.tickResolution
//        if([_midiClock requiredTicksElapsed]) {
//            [_sequencePlayer update:[_midiClock getDiscreteTime]];
//            [_audioManager update:[_midiClock getDiscreteTime]];
//            
//            // We need to check if the metronome has ticked from within the
//            // audio loop because it might be missed by the slower render loop
//            if([_midiClock isMetronomeTick]) {
//                _noteVisualiser.metronomeTick = YES;
//            }
//            
//        }
    }
}

-(void)invokeDelegate:(id)info
{
    [self.timeLineDelegate onTimeInvokeHandler:[NSDate date]];
}

- (void)startLoop {
    
    _isStop = false;

    _timeLineThread = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:nil];
    
    [_timeLineThread start];
    
}

- (void)stopLoop {
    
    _isStop = true;    
    
    [_timeLineThread cancel];
    _timeLineThread = nil;
    
}



// Update the midi clock
//-(void) update {
//    
////    // If this is the first time update is called or
////
////    if(_startTime == Nil) {
////        // Set the start time to the current time
////        [self setupClock];
////    }
////    
////    // Get the time since the clock started
////    NSTimeInterval interval = -[_startTime timeIntervalSinceNow];
////    
////    // Use this time to get an accurate value for the
////    // time since the clock last ticked
////    _distanceTime = interval - _previousTime;
////    
////    // Calculate the MIDI pulse duration
////    double beatDuration = (60.0 / BPM)/PPQN;
////    
////    // If a pulse has happened update the current time in pulses
////    if(_distanceTime > beatDuration) {
////        
////        // Get the number of ticks which happened
////        NSInteger numberOfTicks =  (int) floor(_distanceTime/beatDuration);
////        
////        // Add this to the elapsed ticks
////        _beatsElapsed += numberOfTicks;
////        
////        // And the total number of pulses
////        _beatsCount += numberOfTicks;
////        
////        // Calculate the previous time value. We calculate this
////        // as number of ticks * tick duration so that we account
////        // for the small discrepencies in time i.e. update will
////        // normally be called a small fraction of time late
////        // this stops us from starting to drift away from the real time
////        _previousTime += _beatsCount * beatDuration;
////    }
////    
////    // Sleep the thread for about a third of a pulse to reduce CPU load but ensure
////    // that a pulse is not missed
//    [NSThread sleepForTimeInterval: DEFAULT_INTERVAL];
//    
//}


@end
