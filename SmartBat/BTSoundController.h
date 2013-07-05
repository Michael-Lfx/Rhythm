//
//  BTSoundController.h
//  SmartBat
//
//  Created by poppy on 13-6-30.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTTapController.h"
#import <Accelerate/Accelerate.h>
#import "Novocaine.h"
#import "BTMetronomeCoreController.h"
#import "BTGlobals.h"

@interface BTSoundController : NSObject
{
    BTGlobals * _globals;
   
}

@property(nonatomic, retain) Novocaine *audioManager;
@property(nonatomic, retain) BTTapController *tapController;
@property(nonatomic, assign) bool isLocked;

-(void)record;
-(void)stopRecord;
+(BTSoundController *)sharedInstance;


@end
