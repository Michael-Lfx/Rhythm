//
//  BTTimeLine.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>
#import "BTConstants.h"

@protocol MidiClockDelegate <NSObject>

-(void) onMidiClockTickHandler:(double) time;

@end



@interface BTMidiClock : NSObject
{
    NSUInteger _isStop;
    NSTimeInterval _previousTime;
    NSTimeInterval _distanceTime;
    
    NSUInteger _beatsElapsed;
    NSUInteger _beatsCount;
    NSThread *_timeLineThread;
    
    
    
    NSTimeInterval _clockDuration;
    NSTimeInterval _clockStartTime;
    NSTimeInterval _clockPreviousTickTime;
    int _clockTickCount;
}

@property NSTimeInterval interval;
@property(nonatomic, retain) id<MidiClockDelegate> midiClockDelegate;

-(double)startLoopWithDuration:(NSTimeInterval) duration;
-(double)stopLoop;
-(void)updateClockDuration: (NSTimeInterval) clockDuration;

@end