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
-(void)loadSoundFileForKey: (NSString *) soundFileName withExtension:(NSString *) soundFileExtension forKey:(NSString *) key
{
    
    NSLog(@"loadSoundFileForKey\nfile:%@ , ext: %@, key: %@", soundFileName, soundFileExtension, key);
    
    //get the sound url
    NSURL *soundURL   = [[NSBundle mainBundle] URLForResource: soundFileName withExtension: soundFileExtension];
    NSLog(@"sound url: %@", soundURL);
    
    
    //bind sound file object.
    CFURLRef soundFileURLRef ;
    SystemSoundID soundFileObject;
    soundFileURLRef = (__bridge CFURLRef) soundURL;
    AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
    
    //save soundFileObject to map
    NSNumber *soundIdNumber = [NSNumber numberWithInt:soundFileObject];
    [_soundPool setObject: soundIdNumber forKey:key];

}

//play sound
- (void)playSoundForKey: (NSString *) key{
    
    NSNumber *soundIdNumber = [_soundPool objectForKey:key];
    
    if(soundIdNumber)
    {
        SystemSoundID soundFileObject = [soundIdNumber intValue];
        AudioServicesPlaySystemSound(soundFileObject);
    }
}


//remove sound file
- (void)clearSoundForKey: (NSString *) key{
    
    NSNumber *soundIdNumber = [_soundPool objectForKey:key];
    
    if(soundIdNumber)
    {
        [_soundPool removeObjectForKey:key];
    }
}





//
//-(void)start
//{
//    if (!self.timer)
//    {
//
//        self.bpm = [NSNumber numberWithInt:120];
//        // Calculate the timer interval based on the tempo in beats per minute
//        double interval = 60.0 / [self.bpm doubleValue];
//        
//        NSLog(@"interval: %a", interval);
//        
//        // Start the repeating timer that counts the beats.
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(playSound:) userInfo:[NSNumber numberWithDouble:interval * ([self.meter doubleValue] / 2)] repeats:YES];
//    }
//    else
//    {
//        //todo else
//    }
//}



@end
