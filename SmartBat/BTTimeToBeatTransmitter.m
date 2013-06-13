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
    
    _noteDuration = [self getNoteDurationByBPM:bpm andNote:_note andSubdivision:_subdivisionTemplate];
    
    [_timeLine updateClockDuration:_noteDuration];
}



//measure template
-(void) updateMeasureTemplate:(BTMeasure *) measure
{
    if(_measureTemplate)
    {
        if(measure.noteType && _measureTemplate.noteType != measure.noteType)
        {
            _measureTemplate.noteType = measure.noteType;
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

-(void) startWithBPM:(int)bpm andMeasureTemplate:(BTMeasure *)measureTemplate andSubdivision:(BTSubdivision *) subdivision
{
    
    _bpm = bpm;
    _subdivisionTemplate = subdivision;
    _note = measureTemplate.noteType;
    _noteDuration = [self getNoteDurationByBPM:bpm andNote:_note andSubdivision:_subdivisionTemplate];
    _measureTemplate = measureTemplate;
    
    
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
        [_measureTemplate reset];
        [_subdivisionTemplate reset];
    }
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
    
    NSLog(@"distance: %f", _distance);
    
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
