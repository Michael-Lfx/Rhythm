//
//  BTTimeToBeatTransmitter.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTMeasure.h"

@protocol  BTTimeToBeatTransmitterBeatDelegate<NSObject>

-(void) onBeatHandler: (BTBeat *) beat;

@end

@interface BTTimeToBeatTransmitter : NSObject

@property NSUInteger bpm;



-(void) updateBPM:(NSUInteger) bpm;
-(void) updateMeasure:(BTMeasure *) measure;


@end