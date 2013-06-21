//
//  BTMetronomeCoreController.h
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSimpleFileSoundEngine.h"
#import "BTTimeToBeatTransmitter.h"
#import "BTTimeLine.h"
#import "BTConstants.h"
#import "BTGlobals.h"
#import "TheAmazingAudioEngine.h"
#import <mach/mach_time.h>

@protocol metronomeBeatProtocol <NSObject>

@end

@interface BTMetronomeCoreController : NSObject<BTTimeToBeatTransmitterBeatDelegate>
{
    BTSimpleFileSoundEngine *_simpleFileSoundEngine;
    BTTimeToBeatTransmitter * _timeToBeatTransmitter;
    BTTimeLine * _timeLine;
    BTGlobals* _globals;
    BTMeasure * _measureTemplate;
    BTSubdivision * _subdivisionTemplate;
    
    float _noteType;
    
    //beat type
    BTBeat *_beat_F;
    BTBeat *_beat_P;
    BTBeat * _beat_SUBDIVISION;
    BTBeat * _beat_NIL;
    
    //sound type
    NSString * _soundFile_F;
    NSString * _soundFile_P;
    NSString * _soundFile_SUBDIVISION;
    
    
}


+(BTMetronomeCoreController *) getController;

@property(nonatomic, retain) AEAudioController * audioController;

-(void) start;
-(void) stop;
-(void) pause;
-(void) setBPM:(int)bpm;
-(void) setMeasure:(int)noteCountPerMeasure withNoteType:(float)noteType;

@end
