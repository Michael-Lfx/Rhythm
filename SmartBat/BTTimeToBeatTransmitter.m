//
//  BTTimeToBeatTransmitter.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeToBeatTransmitter.h"

#define SECONDS_PER_MINUTE 60;

@implementation BTTimeToBeatTransmitter

-(id)init
{
    self = [super init];
    
    _timeLineHitCount = 0;
    
    return self;
}

-(void) updateBPM:(NSUInteger) bpm
{
    NSTimeInterval interval = [self getIntervalByBPM:bpm andNote:4];
    [_timeLine updateSleepInterval:interval];
}


-(void) updateMeasureTemplate:(BTMeasure *) measure
{
    //todo
}


-(void) bindTimeLine:(BTTimeLine *) timeLine
{
    _timeLine = timeLine;
    _timeLine.timeLineDelegate = self;
}

-(void) startWithBPM:(int)BPM andNote:(int)note
{
    if(_timeLine)
    {
        NSTimeInterval interval = [self getIntervalByBPM:BPM andNote:note];
        [_timeLine startLoopWithTimeInterval:interval];
    }
}

-(void)stop
{
    if(_timeLine)
    {
        [_timeLine stopLoop];
    }
}


-(NSTimeInterval)getIntervalByBPM:(int)bpm andNote:(int)note
{
    NSTimeInterval timeInterval;
    
    timeInterval = 60.0 / bpm;
    
    //todo 
    
    NSLog(@"getIntervalByBPMAndNote: %f", timeInterval);
    
    return timeInterval;
}


//implement of TimeLineDelegate
-(void)onTimeInvokeHandler: (NSDate *) time
{
    _timeLineHitCount ++;
    
    
        
        NSTimeInterval point = [time timeIntervalSince1970];
        
        long long dTime = [[NSNumber numberWithDouble:point] longLongValue]; // 将double转为long long型
        
        NSLog(@"[%llu][%d]timeline invoke with interval! %@", dTime ,_timeLineHitCount, time);
        
        [self.timeToBeatTransmitterBeatDelegate onBeatHandler:nil ofMeasure:nil withBPM:nil];

    
}

@end
