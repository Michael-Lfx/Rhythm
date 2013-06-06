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

#define DEFAULT_BPM 120
#define DEFAULT_BEAT 4
#define DEFAULT_NOTE 4

-(id)init
{
    self = [super init];
    
    //init sound engine;
    _simpleFileSoundEngine = [BTSimpleFileSoundEngine getEngine];
    [_simpleFileSoundEngine loadSoundFileForKey:DEFAULT_P_SOUND_FILE withExtension:DEFAULT_SOUND_FILE_EXT forKey:TICK_SOUND_KEY];

    
    //init timeLine
    _timeLine = [[BTTimeLine alloc]init];
    
    
    
    //init a measure for template which would be used for a transmiter
    BTMeasure * measure = [[BTMeasure alloc]initWithBeatAndNote:DEFAULT_BEAT withNote:DEFAULT_NOTE];
    
    
    
    //init transmitter
    _timeToBeatTransmitter = [[BTTimeToBeatTransmitter alloc]init];
    [_timeToBeatTransmitter bindTimeLine:_timeLine];
    [_timeToBeatTransmitter updateBPM:DEFAULT_BPM];
    [_timeToBeatTransmitter updateMeasureTemplate:measure];
    
    _timeLine.timeLineDelegate = _timeToBeatTransmitter;
    
    
    
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

-(void)onBeatHandler:(BTBeat *)beat ofMeasure:(BTMeasure *)measure withBPM:(NSUInteger)bpm
{
    NSLog(@"beat of timeline! bpm: %d, beatIndex: %d", bpm, beat.indexOfMeasure);
}

@end