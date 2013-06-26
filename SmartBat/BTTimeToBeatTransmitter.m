//
//  BTTimeToBeatTransmitter.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeToBeatTransmitter.h"

#define SECONDS_PER_MINUTE 60;
#define DEFAULT_DURATION 0.5;

@implementation BTTimeToBeatTransmitter

-(id)init
{
    self = [super init];
    
    _globals = [BTGlobals sharedGlobals];
    _beatCount = 0;
    _minDistance = 100000000.0;
    _maxDistance =0;
    _avarageDistance = 0;
    _totalDistance = 0;
    
    return self;
}


//bpm
-(void) updateBPM:(int) bpm
{
    _bpm = bpm;
    
    _noteDuration = [self getNoteDurationByBPM:bpm andNote:_measureTemplate.noteType andSubdivision:_subdivisionTemplate];
    
    [self updateClockDuration];
}



//measure template
-(void) updateMeasureTemplate:(BTMeasure *) measureTemplate
{

    _noteDuration = [self getNoteDurationByBPM:_bpm andNote:measureTemplate.noteType andSubdivision:_subdivisionTemplate];
       

    _measureTemplate = measureTemplate;
     [self updateClockDuration];
}


-(void) updateSubdivisionTemplate:(BTSubdivision *)subdivisionTemplate
{

    _noteDuration = [self getNoteDurationByBPM:_bpm andNote:_measureTemplate.noteType andSubdivision:subdivisionTemplate];
        
    _subdivisionTemplate = subdivisionTemplate;
    [self updateClockDuration];
}


-(BTMeasure *)getMeasureTemplate
{
    return _measureTemplate;
}


-(void)updateClockDuration
{
    
    _globals.currentSubdivisionDuration = _noteDuration;
    _globals.currentNoteDuration = _noteDuration * [_subdivisionTemplate count];
    _globals.currentMeasureDuration = _noteDuration * [_subdivisionTemplate count] * [_measureTemplate getNoteCount ];
    
    [_timeLine updateClockDuration:_noteDuration];
}




-(void) bindTimeLine:(BTTimeLine *) timeLine
{
    _timeLine = timeLine;
    _timeLine.timeLineDelegate = self;
}

-(double) startWithBPM:(int)bpm andMeasureTemplate:(BTMeasure *)measureTemplate andSubdivision:(BTSubdivision *) subdivision
{
    
    _bpm = bpm;
    _subdivisionTemplate = subdivision;
    _noteDuration = [self getNoteDurationByBPM:bpm andNote:measureTemplate.noteType andSubdivision:_subdivisionTemplate];
    _measureTemplate = measureTemplate;
    
    
    if(_timeLine)
    {
        
        [self updateClockDuration];
        return [_timeLine startLoopWithDuration:_noteDuration];
    }
    
    return -1;
}

-(double)start
{
    if(_timeLine)
    {
        return [_timeLine startLoopWithDuration:_noteDuration];
    }
    return -1;
}

-(double)stop
{
    if(_timeLine)
    {
        
        [_measureTemplate reset];
        [_subdivisionTemplate reset];
        return [_timeLine stopLoop];
    }
    return -1;
}

-(double)getNoteDurationByBPM:(int) bpm andNote:(double)note andSubdivision:(BTSubdivision *)subdivision
{
    double duration = 60.0/(bpm/(note*4)* [subdivision count]);
    return duration;
}

-(double) getNowTime
{
    return [[NSDate date] timeIntervalSince1970];
}

//implement of TimeLineDelegate
-(void)onTimeInvokeHandler: (uint64_t) time
{
    
    
    mach_timebase_info_data_t data;
    mach_timebase_info(&data);
    
    NSTimeInterval _point = mach_absolute_time() * 1.0e-9;
    _point *= data.numer;
    _point /= data.denom;

    
    NSTimeInterval _distance = _point - _previousTime;
    _previousTime = _point;
    
    _beatCount ++;
    
//    NSLog(@"distance: %f", _distance);
    
    BTBeat * beat = [_measureTemplate getCurrentNote];
    beat.indexOfMeasure = _measureTemplate.playIndex;
    beat.indexOfSubdivision = _subdivisionTemplate.playIndex;

    
    switch(_subdivisionTemplate.playIndex)
    {
        case 0:
            [self.timeToBeatTransmitterBeatDelegate onBeatHandler:beat ofMeasure:_measureTemplate withBPM:_bpm];
            
            [_measureTemplate playNote];
            [_subdivisionTemplate playNote ];
            
            break;
        default:
            [self.timeToBeatTransmitterBeatDelegate onSubdivisionHandler:beat];
            
            [_subdivisionTemplate playNote ];
            break;
    }
    

    

}

@end
