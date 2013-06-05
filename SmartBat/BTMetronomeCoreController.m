//
//  BTMetronomeCoreController.m
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMetronomeCoreController.h"

@implementation BTMetronomeCoreController
@synthesize simpleFileSoundEngine, clock;

#define TICK_SOUND_KEY @"P"

-(id)init
{
    self = [super init];
    
    
    self.simpleFileSoundEngine = [BTSimpleFileSoundEngine getEngine];
    
    self.clock = [[BTClock alloc]init];
    self.clock.delegate = self;
    
    return self;
}

-(void)start
{
    
    //test simpldFileSoundEngine! --poppy
    
    [self.simpleFileSoundEngine loadSoundFileForKey:@"tick" withExtension:@"aif" forKey:TICK_SOUND_KEY];
    
        
    [self.clock startDriverThread];
    
}

-(void)stop
{
    [self.clock stopDriverThread];
}

-(void)pause
{
    //todo
}

-(void)beatOnHandler:(int)beatCount
{
    NSLog(@"beat! %d", beatCount);
    [self.simpleFileSoundEngine playSoundForKey:TICK_SOUND_KEY];
    
}

@end
