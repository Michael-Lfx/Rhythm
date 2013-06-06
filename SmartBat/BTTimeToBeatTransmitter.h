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



@protocol  BTTimeToBeatTransmitterBeatDelegate<NSObject>

-(void) onBeatHandler: (BTBeat *) beat ofMeasure:(BTMeasure *) measure withBPM:(NSUInteger)bpm;

@end





@interface BTTimeToBeatTransmitter : NSObject<TimeLineDelegate>{
    
    BTTimeLine * _timeLine;
    NSUInteger _timeLineHitCount;
}


@property NSUInteger bpm;
@property(nonatomic, retain) id<BTTimeToBeatTransmitterBeatDelegate>timeToBeatTransmitterBeatDelegate;

-(void) updateBPM:(NSUInteger) bpm;
-(void) updateMeasureTemplate:(BTMeasure *) measure;
-(void) bindTimeLine:(BTTimeLine *) timeLine;

@end