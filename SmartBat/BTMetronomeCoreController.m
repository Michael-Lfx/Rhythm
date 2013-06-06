//
//  BTMetronomeCoreController.m
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMetronomeCoreController.h"

@implementation BTMetronomeCoreController

#define TICK_SOUND_KEY @"P"
#define DEFAULT_P_SOUND_FILE @"tick"
#define DEFAULT_SOUND_FILE_EXT @"aif"

-(id)init
{
    self = [super init];
    
    
    _simpleFileSoundEngine = [BTSimpleFileSoundEngine getEngine];
    
    _clock = [[BTClock alloc]init];
    _clock.beatDelegate = self;
    
    return self;
}

+(BTMetronomeCoreController *)getController
{
    static BTMetronomeCoreController *sharedMetronomeCoreController = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedMetronomeCoreController = [[self alloc] init];
    });
    return sharedMetronomeCoreController;
}

-(void)start
{

    [_simpleFileSoundEngine loadSoundFileForKey:DEFAULT_P_SOUND_FILE withExtension:DEFAULT_SOUND_FILE_EXT forKey:TICK_SOUND_KEY];
    [_clock startDriverThread];
    
}

-(void)stop
{
    [_clock stopDriverThread];
}

-(void)pause
{
    //todo
}

-(void)setBpm:(int)bpm
{
    [_clock setBpm:bpm];
}

-(void)onBeatHandler:(int)beatCount
{
    NSLog(@"beat! %d", beatCount);
    [_simpleFileSoundEngine playSoundForKey:TICK_SOUND_KEY];
    
}

@end
