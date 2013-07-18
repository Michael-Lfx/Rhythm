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
#import "OALSimpleAudio.h"
#import "Novocaine.h"






@interface BTSimpleFileSoundEngine : NSObject
{
    
    NSMutableDictionary * _soundPool;
    Novocaine * _audioManager;
}

//@property (nonatomic,retain) NSMutableDictionary * soundPool;

+(BTSimpleFileSoundEngine *)getEngine;
-(void)loadSoundFile: (NSString *) soundFileName withExtension:(NSString *)extension;
-(void)playSound: (NSString *)soundFileName  withExtension:(NSString *)extension;


@end
