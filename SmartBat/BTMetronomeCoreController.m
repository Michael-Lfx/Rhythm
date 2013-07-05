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
#define DEFAULT_SOUNDFILE_F @"default_f"
#define DEFAULT_SOUNDFILE_P @"default_p"
#define DEFAULT_SOUNDFILE_SUBDIVISION @"default_subdivision"
#define DEFAULT_SOUND_FILE_EXT @"caf"

#define DEFAULT_BPM 120
#define DEFAULT_BEAT 4
#define DEFAULT_NOTE 4

#define SYSTEM_LATENCY 0.005f

-(id)init
{
    self = [super init];
    
    _globals = [BTGlobals sharedGlobals];
    
    [_globals addObserver:self forKeyPath:@"beatPerMinute" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"beatPerMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"noteType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"subdivision" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    
    //init sound engine;
    _soundFile_F = DEFAULT_SOUNDFILE_F;
    _soundFile_P = DEFAULT_SOUNDFILE_P;
    _soundFile_SUBDIVISION = DEFAULT_SOUNDFILE_SUBDIVISION;
    
    _simpleFileSoundEngine = [BTSimpleFileSoundEngine getEngine];
    [_simpleFileSoundEngine loadSoundFile:_soundFile_F withExtension:DEFAULT_SOUND_FILE_EXT];
    [_simpleFileSoundEngine loadSoundFile:_soundFile_P withExtension:DEFAULT_SOUND_FILE_EXT];
    [_simpleFileSoundEngine loadSoundFile:_soundFile_SUBDIVISION withExtension:DEFAULT_SOUND_FILE_EXT];

    
    //init timeLine
    _timeLine = [[BTTimeLine alloc]init];
    
    
    
    //prepare beat type
    _beat_F = [[BTBeat alloc]initWithBeatType:BTBeatType_F];
    _beat_P = [[BTBeat alloc]initWithBeatType:BTBeatType_P];
    _beat_NIL = [[BTBeat alloc]initWithBeatType:BTBeatType_NIL];
    _beat_SUBDIVISION = [[BTBeat alloc]initWithBeatType:BTBeatType_SUBDIVISION];

      
    [self setMeasure:_globals.beatPerMeasure withNoteType:_globals.noteType];
    [self setSubdivision:_globals.subdivision];
    
    //init transmitter
    _timeToBeatTransmitter = [[BTTimeToBeatTransmitter alloc]init];
    [_timeToBeatTransmitter bindTimeLine:_timeLine];
    
    
    _timeToBeatTransmitter.timeToBeatTransmitterBeatDelegate = self;
    
    
    [self setBPM: _globals.beatPerMinute];
    [self setMeasure:_globals.beatPerMeasure withNoteType:_globals.noteType];
    [self setSubdivision:_globals.subdivision];
    
    
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
    double startTime =  [_timeToBeatTransmitter start];
    
    NSLog(@"metronome start");

    [self updateSystemStatus:YES andPlayStatusChangedTime:startTime];
    
}

-(void)startAfter:(NSTimeInterval)timeInterval
{
    NSLog(@"%f", timeInterval);
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(start) userInfo:nil repeats:NO];}

-(void)stop
{
    double stopTime = [_timeToBeatTransmitter stop] ;
    [self updateSystemStatus:NO andPlayStatusChangedTime:stopTime];
}

-(void)pause
{
    //todo
}

-(void)setBPM:(int)bpm
{
    [_timeToBeatTransmitter updateBPM:bpm];
}


-(void)setMeasure:(int)noteCountPerMeasure withNoteType:(float)noteType
{
    _noteType = noteType;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithObjects:_beat_F, nil];
    
    for(int n=1; n < noteCountPerMeasure; n++)
    {
        [tempArray addObject:_beat_P];
    }
    
    _measureTemplate = [[BTMeasure alloc]initWithBeat:tempArray andNoteType:noteType];
    
    [self setGlobalMeasure];
    
    [_timeToBeatTransmitter updateMeasureTemplate:_measureTemplate];
}

-(void)setGlobalMeasure
{
    
    NSMutableArray * tempArray = [[NSMutableArray alloc]initWithObjects:nil];
    
    for( int n =0 ; n<[_measureTemplate getNoteCount]; n++)
    {
        BTBeat * beat = [_measureTemplate getNote:n];
        
        NSNumber * type = [[NSNumber alloc]initWithInt:beat.beatType];
        
        [tempArray insertObject:type atIndex:n];
        
    }
    _globals.currentMeasure = tempArray;
}


-(void)setSubdivision:(int)subdivisionCount
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithObjects:nil];
    
    for(int n=0; n < subdivisionCount; n++)
    {
        [tempArray addObject:_beat_SUBDIVISION];
    }

    _subdivisionTemplate = [[BTSubdivision alloc]initWithBeat:tempArray];
    
    [_timeToBeatTransmitter updateSubdivisionTemplate:_subdivisionTemplate];
}




-(void)updateSystemStatus:(BOOL) playStatus andPlayStatusChangedTime:(double)changeTime
{
    NSMutableDictionary * tempSystemStatus = [[NSMutableDictionary alloc]init];
    
    NSNumber * tempPlayStatus = [[NSNumber alloc]initWithBool:playStatus];
    NSNumber * tempPlayStatusChangedTime = [[NSNumber alloc]initWithDouble:changeTime];
    
    [tempSystemStatus setValue:tempPlayStatus forKey:@"playStatus"];
    [tempSystemStatus setValue:tempPlayStatusChangedTime forKey:@"playStatusChangedTime"];

    _globals.systemStatus = tempSystemStatus;
}




//global observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beatPerMinute"])
    {
        [self setBPM: _globals.beatPerMinute];
    }
    
    if([keyPath isEqualToString:@"beatPerMeasure"])
    {
        [self setMeasure:_globals.beatPerMeasure withNoteType:_globals.noteType];
    }
    
    if([keyPath isEqualToString:@"noteType"])
    {
        [self setMeasure:_globals.beatPerMeasure withNoteType:_globals.noteType];
    }
    
    if([keyPath isEqualToString:@"subdivision"])
    {
        [self setSubdivision:_globals.subdivision];
    }
}




//delegate
-(void)onBeatHandler:(BTBeat *)beat ofMeasure:(BTMeasure *)measure withBPM:(int)bpm
{
//    NSLog(@"beat of timeline! bpm: %d, beatIndex: %d", bpm, measure.playIndex);
    
    NSNumber * indexOfMeasure = [[NSNumber alloc]initWithInt:beat.indexOfMeasure];
    NSNumber * hitTime = [[NSNumber alloc]initWithDouble:beat.hitTime];
    NSNumber * type = [[NSNumber alloc]initWithInt:beat.beatType];
    
    NSMutableDictionary * tempBeatInfo = [[NSMutableDictionary alloc]init];
    
    [tempBeatInfo setValue:indexOfMeasure forKey:@"indexOfMeasure"];
    [tempBeatInfo setValue:hitTime forKey:@"hitTime"];
    [tempBeatInfo setValue:type forKey:@"type"];
    
    
    _globals.beatInfo = tempBeatInfo;
    
}

-(void)onSubdivisionHandler:(BTBeat *)beat
{
//    [_simpleFileSoundEngine playSound:_soundFile_SUBDIVISION  withExtension:DEFAULT_SOUND_FILE_EXT];
}

-(void)onSoundBeatHandler:(BTBeat *)beat ofMeasure:(BTMeasure *)measure withBPM:(int)bpm
{
    //    NSLog(@"beat of timeline! bpm: %d, beatIndex: %d", bpm, measure.playIndex);
    
    BTBeatType beatType = beat.beatType;
    
    switch(beatType)
    {
        case BTBeatType_F:
            [_simpleFileSoundEngine playSound:_soundFile_F  withExtension:DEFAULT_SOUND_FILE_EXT];
            
            break;
        case BTBeatType_P:
            [_simpleFileSoundEngine playSound:_soundFile_P  withExtension:DEFAULT_SOUND_FILE_EXT];
            break;
        case BTBeatType_NIL:
            break;
        default:
            break;
    }
    
}

-(void)onSoundSubdivisionHandler:(BTBeat *)beat
{
    [_simpleFileSoundEngine playSound:_soundFile_SUBDIVISION  withExtension:DEFAULT_SOUND_FILE_EXT];
}

-(void)bindSoundProfile: (NSString *)_profileName
{
    
    //todo: change sound from a plist file
    //[_simpleFileSoundEngine loadSoundFile:DEFAULT_SOUNDFILE_P];
}
//
//
//
//-(void)turnOnLed
//{
//    if ([_device hasTorch]) {
//        [_device lockForConfiguration:nil];
//        [_device setTorchMode: AVCaptureTorchModeOn];
//        [_device unlockForConfiguration];
//    }
//}
//
//-(void)turnOffLed
//{
//    if ([_device hasTorch]) {
//        [_device lockForConfiguration:nil];
//        [_device setTorchMode: AVCaptureTorchModeOff];
//        [_device unlockForConfiguration];
//    } 
//}


@end
