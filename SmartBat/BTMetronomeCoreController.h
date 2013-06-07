//
//  BTMetronomeCoreController.h
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSimpleFileSoundEngine.h"
#import "BTTimeToBeatTransmitter.h"
#import "BTTimeLine.h"
#import "BTConstants.h"
#import "BTGlobals.h"

@interface BTMetronomeCoreController : NSObject<BTTimeToBeatTransmitterBeatDelegate>
{
    BTSimpleFileSoundEngine *_simpleFileSoundEngine;
    BTTimeToBeatTransmitter * _timeToBeatTransmitter;
    BTTimeLine * _timeLine;
    BTGlobals* _globals;
}


+(BTMetronomeCoreController *) getController;

-(void) start;
-(void) stop;
-(void) pause;
-(void) setBPM:(int)bpm;

@end
