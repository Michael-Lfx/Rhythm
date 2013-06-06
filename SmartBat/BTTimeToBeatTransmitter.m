//
//  BTTimeToBeatTransmitter.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeToBeatTransmitter.h"

@implementation BTTimeToBeatTransmitter

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
-(void)onTimeInvokeHandler:(NSTimeInterval) interval
{
    NSLog(@"timeline invoke with interval!");
}

@end
