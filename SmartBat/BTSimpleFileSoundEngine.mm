//
//  SimpleFileSoundEngine.h
//  SmartBat
//
//  Created by poppy on 13-6-4.
//  Copyright (c) 2013年 sensor-music.com. All rights reserved.
//

#import "BTSimpleFileSoundEngine.h"
#import "AudioFileReader.h"


@implementation BTSimpleFileSoundEngine



-(BTSimpleFileSoundEngine *)init{
    self = [super init];
    
    if (self) {
        _soundPool = [[NSMutableDictionary alloc]init];
        
        _audioManager = [Novocaine audioManager];

    }
    
    return self;
}

+(BTSimpleFileSoundEngine *)getEngine
{
    static BTSimpleFileSoundEngine *sharedEngine = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedEngine = [[self alloc] init];
    });
    return sharedEngine;
}





// prepare sound file from APP resource
-(void)loadSoundFile: (NSString *) soundFileName withExtension:(NSString *)extension
{
    [[OALSimpleAudio sharedInstance] preloadEffect:[NSString stringWithFormat:@"%@.%@",soundFileName,extension]];
    
    
//    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:soundFileName withExtension:extension];
//
//    AudioFileReader *fileReader = [[AudioFileReader alloc]
//                       initWithAudioFileURL:inputFileURL
//                       samplingRate:_audioManager.samplingRate
//                       numChannels:_audioManager.numOutputChannels];
//    
//    
//        
//    
//    [_soundPool setObject:fileReader forKey:soundFileName];
}

//play sound
- (void)playSound: (NSString *) soundFileName withExtension:(NSString *)extension
{
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.%@",soundFileName,extension]];
    
    
//    AudioFileReader *fileReader = [_soundPool valueForKey:soundFileName];
//    
//    if(!fileReader)
//    {
//        [self loadSoundFile:soundFileName withExtension:extension];
//    }
//    
//    [_audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//     {
////         [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
//         NSLog(@"Time: %f", fileReader.currentTime);
//     }];
//    
//    [fileReader setCurrentTime:0.0];
//    
//    [fileReader play];
    
}





@end
