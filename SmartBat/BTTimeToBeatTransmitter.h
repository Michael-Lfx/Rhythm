//
//  BTTimeToBeatTransmitter.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTMeasure.h"
#import "BTTimeLine.h"
#import "BTSubdivision.h"
#import "BTGlobals.h"

//protocal
@protocol  BTTimeToBeatTransmitterBeatDelegate<NSObject>

-(void) onBeatHandler: (BTBeat *) beat ofMeasure:(BTMeasure *) measure withBPM:(int)bpm;
-(void) onSubdivisionHandler: (BTBeat *) beat;

@end




//interface
@interface BTTimeToBeatTransmitter : NSObject<TimeLineDelegate>{
    
    
    BTGlobals * _globals;
    BTTimeLine * _timeLine;
    
    NSTimeInterval _startTime;
    NSTimeInterval _previousTime;
    NSTimeInterval _distanceTime;
    
    double _noteDuration;
    int _beatCount;

    double _note;
    int _bpm;
    
    BTMeasure * _measureTemplate;
    BTSubdivision * _subdivisionTemplate;
    
    NSTimeInterval _minDistance;
    NSTimeInterval _maxDistance;
    NSTimeInterval _totalDistance;
    NSTimeInterval _avarageDistance;

}

@property int bpm;
@property(nonatomic, retain) id<BTTimeToBeatTransmitterBeatDelegate>timeToBeatTransmitterBeatDelegate;

-(void) updateBPM:(int) bpm;
-(void) updateMeasureTemplate:(BTMeasure *) measure;
-(void)updateSubdivisionTemplate:(BTSubdivision *) subdivision;
-(BTMeasure *)getMeasureTemplate;
-(void) bindTimeLine:(BTTimeLine *) timeLine;
-(double) startWithBPM:(int)BPM andMeasureTemplate:(BTMeasure *) measureTemplate andSubdivision:(BTSubdivision *) subdivision;
-(double)start;
-(double) stop;

@end