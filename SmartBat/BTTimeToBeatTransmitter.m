//
//  BTTimeToBeatTransmitter.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeToBeatTransmitter.h"

@implementation BTTimeToBeatTransmitter

-(id)init
{
    self = [super init];
    
    _timeLineHitCount = 0;
    
    return self;
}

-(void) updateBPM:(NSUInteger) bpm
{
    
}


-(void) updateMeasureTemplate:(BTMeasure *) measure
{
    
}


-(void) bindTimeLine:(BTTimeLine *) timeLine
{
    _timeLine = timeLine;
    _timeLine.timeLineDelegate = self;
}


//implement of TimeLineDelegate
-(void)onTimeInvokeHandler: (NSDate *) time
{
    _timeLineHitCount ++;
    
    if(_timeLineHitCount % 100 ==0)
    {
        NSLog(@"[%d]timeline invoke with interval! %@",_timeLineHitCount, time);
        
        [self.timeToBeatTransmitterBeatDelegate onBeatHandler:nil ofMeasure:nil withBPM:nil];

    }
    
}

@end
