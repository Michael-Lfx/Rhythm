//
//  SimpleFileSoundEngine.h
//  SmartBat
//
//  Created by poppy on 13-6-4.
//  Copyright (c) 2013年 sensor-music.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "OALSimpleAudio.h"

@interface BTSimpleFileSoundEngine : NSObject
{
    NSMutableDictionary * _soundPool;
}


+(BTSimpleFileSoundEngine *)getEngine;
-(void)loadSoundFile: (NSString *) soundFileName;
-(void)playSound: (NSString *)soundFileName;

@end
