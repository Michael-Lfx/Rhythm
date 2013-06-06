//
//  BTMetronomeCoreController.h
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSimpleFileSoundEngine.h"
#import "BTClock.h"
#import "BTTimeToBeatTransmitter.h"
#import "BTTimeLine.h"

@interface BTMetronomeCoreController : NSObject<ClockBeatDelegate, BTTimeToBeatTransmitterBeatDelegate>
{
    BTSimpleFileSoundEngine *_simpleFileSoundEngine;
    BTTimeToBeatTransmitter * _timeToBeatTransmitter;
    BTTimeLine * _timeLine;
    BTClock *_clock;
}


+(BTMetronomeCoreController *) getController;

-(void) start;
-(void) stop;
-(void) pause;
-(void) setBpm:(int)bpm;

@end
