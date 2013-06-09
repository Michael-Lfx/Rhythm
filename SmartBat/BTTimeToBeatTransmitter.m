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
    
    _beatCount = 0;
    
    return self;
}


//bpm
-(void) updateBPM:(int) bpm
{
    _bpm = bpm;
    
    _noteDuration = [self getNoteDurationByBPM:bpm andNote:_note];
    
    [_timeLine updateClockDuration:_noteDuration];
}



//measure template
-(void) updateMeasureTemplate:(BTMeasure *) measure
{
    if(_measureTemplate)
    {
        if(measure.note && _measureTemplate.note != measure.note)
        {
            _measureTemplate.note = measure.note;
        }
    
        if(measure.beat && _measureTemplate.beat != measure.beat)
        {
            _measureTemplate.beat = measure.beat;
        }
    }
}

-(BTMeasure *)getMeasureTemplate
{
    return _measureTemplate;
}




-(void) bindTimeLine:(BTTimeLine *) timeLine
{
    _timeLine = timeLine;
    _timeLine.timeLineDelegate = self;
}

-(void) startWithBPM:(int)bpm andMeasureTemplate:(BTMeasure *)measureTemplate
{
    
    _bpm = bpm;
    _note = measureTemplate.note;    
    _noteDuration = [self getNoteDurationByBPM:bpm andNote:_note];
    
    if(_timeLine)
    {
        
        if(!_startTime)
        {
            _startTime = [self getNowTime];
        }

        [_timeLine startLoopWithDuration:_noteDuration];
    }
}

-(void)stop
{
    if(_timeLine)
    {
        [_timeLine stopLoop];
    }
}


-(NSTimeInterval)getIntervalByBPM:(int)bpm andNote:(double)note
{
    NSTimeInterval duration = _noteDuration;
    
    duration = [self accurateTimeInterval:duration];
    
    NSLog(@"getIntervalByBPMAndNote: %f", duration);
    
    return duration;
}

-(NSTimeInterval)accurateTimeInterval:(NSTimeInterval) duration
{
    if(_startTime)
    {
        NSTimeInterval targetTime = _noteDuration + (_startTime + _noteDuration * (_beatCount) - _previousTime);
        
        NSLog(@"actully target duration: %f, beatCount: %d", targetTime, _beatCount);
        
        return targetTime;
    }
    else
    {
        return duration;
    }
}

-(double)getNoteDurationByBPM:(int) bpm andNote:(double)note
{
    double duration = 60.0/(bpm/(note*4));
    return duration;
}

-(double) getNowTime
{
    return [[NSDate date] timeIntervalSince1970];
}

//implement of TimeLineDelegate
-(void)onTimeInvokeHandler: (uint64_t) time
{
    

    NSTimeInterval point = mach_absolute_time();

    NSLog(@"distance: %f", (point - _previousTime)*1.0e-9);
    
    _previousTime = point;
    _beatCount ++;

//    [_timeLine updateSleepInterval:[self getIntervalByBPM:_bpm andNote:_note ]];
    
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
    
        [self.timeToBeatTransmitterBeatDelegate onBeatHandler:nil ofMeasure:nil withBPM:_bpm];
        
//    });

    
    
}

@end
