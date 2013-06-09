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
#define DEFAULT_P_SOUND_FILENAME @"tick.aif"
#define DEFAULT_SOUND_FILE_EXT @"aif"

#define DEFAULT_BPM 120
#define DEFAULT_BEAT 4
#define DEFAULT_NOTE 4

-(id)init
{
    self = [super init];
    
    _globals = [BTGlobals sharedGlobals];
    [_globals addObserver:self forKeyPath:@"beatPerMinute" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    
    //init sound engine;
    _simpleFileSoundEngine = [BTSimpleFileSoundEngine getEngine];
    [_simpleFileSoundEngine loadSoundFile:DEFAULT_P_SOUND_FILENAME];

    
    //init timeLine
    _timeLine = [[BTTimeLine alloc]init];
    
    
    
    //init a measure for template which would be used for a transmiter
    //BTMeasure * measure = [[BTMeasure alloc]initWithBeatAndNote:DEFAULT_BEAT withNote:DEFAULT_NOTE];
    
    
    
    //init transmitter
    _timeToBeatTransmitter = [[BTTimeToBeatTransmitter alloc]init];
    [_timeToBeatTransmitter bindTimeLine:_timeLine];
    //[_timeToBeatTransmitter updateMeasureTemplate:measure];
    _timeToBeatTransmitter.timeToBeatTransmitterBeatDelegate = self;
    
    
    
    
    
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
    BTMeasure * _measureTemplate = [[BTMeasure alloc]initWithBeat:4 andNote:0.25];
    
    [_timeToBeatTransmitter startWithBPM:_globals.beatPerMinute andMeasureTemplate:_measureTemplate];
}


-(void)stop
{
    [_timeToBeatTransmitter stop] ;
}

-(void)pause
{
    //todo
}

-(void)setBPM:(int)bpm
{
    [_timeToBeatTransmitter updateBPM:bpm];
}



//global observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beatPerMinute"])
    {
        [self setBPM: _globals.beatPerMinute];
    }
}




//delegate
-(void)onBeatHandler:(BTBeat *)beat ofMeasure:(BTMeasure *)measure withBPM:(int)bpm
{
    NSLog(@"beat of timeline! bpm: %d, beatIndex: %d", bpm, beat.indexOfMeasure);
    [_simpleFileSoundEngine playSound:DEFAULT_P_SOUND_FILENAME];
}

@end
