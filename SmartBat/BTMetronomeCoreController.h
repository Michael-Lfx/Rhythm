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

@interface BTMetronomeCoreController : NSObject<BeatOnDelegate>
{
    BTSimpleFileSoundEngine *_simpleFileSoundEngine;
    BTClock *_clock;
}


+(BTMetronomeCoreController *) getController;

-(void) start;
-(void) stop;
-(void) pause;
-(void) setBpm:(int)bpm;

@end
