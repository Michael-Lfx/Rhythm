//
//  BTTimeLine.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimeLineDelegate <NSObject>

-(void) onTimeInvokeHandler:(NSDate *) time;

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
}

@property NSTimeInterval interval;
@property(nonatomic, retain) id<TimeLineDelegate> timeLineDelegate;

-(void)startLoopWithTimeInterval:(NSTimeInterval) timeInterval;
-(void)stopLoop;
-(void)updateSleepInterval:(NSTimeInterval) sleepInterval;

@end