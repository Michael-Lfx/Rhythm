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

@interface BTSimpleFileSoundEngine : NSObject
{
    NSMutableDictionary * soundPool;
}


+(BTSimpleFileSoundEngine *)getEngine;
-(void)loadSoundFileForKey: (NSString *) soundFileName withExtension:(NSString *) soundFileExtension forKey:(NSString *) key;
-(void)playSoundForKey: (NSString *)key;
-(void)clearSoundForKey: (NSString *)key;

@end
