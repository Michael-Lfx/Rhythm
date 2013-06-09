//
//  BTTimeLine.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>

@protocol TimeLineDelegate <NSObject>

-(void) onTimeInvokeHandler:(uint64_t) time;

@end



@interface BTTimeLine : NSObject
{
    NSUInteger _isStop;
    NSDate * _startTime;
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
@property(nonatomic, retain) id<TimeLineDelegate> timeLineDelegate;

-(void)startLoopWithDuration:(NSTimeInterval) duration;
-(void)stopLoop;
-(void)updateClockDuration: (NSTimeInterval) clockDuration;

@end