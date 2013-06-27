//
//  BTTapController.h
//  SmartBat
//
//  Created by poppy on 13-6-21.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>
#import "BTGlobals.h"

@protocol TapBeatProtocal <NSObject>

-(void) processTapBPM: (int)BPM;

@end

@interface BTTapController : NSObject
{
    int _targetCount;
    NSTimer  * _timer;
    NSMutableArray * _hitPointArray;
    
    BTGlobals * _globals;
}


-(void)updateTargetCount:(int)tapCount;
-(int)tap;
-(void)reset;
-(int)currentTapCount;
-(int) targetTapCount;

@end
