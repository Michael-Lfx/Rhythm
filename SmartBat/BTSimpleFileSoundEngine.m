//
//  SimpleFileSoundEngine.h
//  SmartBat
//
//  Created by poppy on 13-6-4.
//  Copyright (c) 2013年 sensor-music.com. All rights reserved.
//

#import "BTSimpleFileSoundEngine.h"

@implementation BTSimpleFileSoundEngine


-(BTSimpleFileSoundEngine *)init{
    self = [super init];
    
    if (self) {
        _soundPool = [NSMutableDictionary dictionary];
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
-(void)loadSoundFile: (NSString *) soundFileName
{
    [[OALSimpleAudio sharedInstance] preloadEffect:soundFileName];
}

//play sound
- (void)playSound: (NSString *) soundFileName{
    [[OALSimpleAudio sharedInstance] playEffect:soundFileName];
}


@end
