//
//  BTSoundController.m
//  SmartBat
//
//  Created by poppy on 13-6-30.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//



#import "BTSoundController.h"

#define BUS_OUTPUT_TO_HARDWARE 0
#define BUS_INPUT_FROM_HARDWARE 1


#define DEFAULT_LOCK_FRAMES 100;

@implementation BTSoundController

-(id)init
{
    self = [super init];
//    self.audioManager = [Novocaine audioManager];

    
    self.tapController = [BTTapController sharedInstance];
    _globals = [BTGlobals sharedGlobals];
    
//    [self initInput];
    
    return self;
}


+(BTSoundController *)sharedInstance
{
    static BTSoundController *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)record
{
    
    NSLog(@"start record!!!");
    
    
    self.isLocked = YES;

    
}

-(void)unLock
{
    NSLog(@"unlock");
    self.isLocked = NO;
}


-(void)stopRecord
{

}


-(void)initInput
{
    
    __block BTSoundController *soundController = self;
    __block float dbVal = 0.0;
    
    __block UInt32 durationFrames = 0;
    __block UInt32 lastHitFrame = 0;
    
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {

        
        durationFrames ++;
        
        if(!soundController.isLocked){
            vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
            float meanVal = 0.0;
            vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);
        
            float one = 1.0;
            vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
            dbVal = dbVal + 0.2*(meanVal - dbVal);
        
            
            printf("Decibel level: %f\n", dbVal);
        
            if(dbVal > -45 && dbVal < -30)
            {
                
                int tapCount = [soundController.tapController tap];
                
                NSLog(@"tapCount:%d", tapCount);
                
                if(tapCount > 0)
                {
                    
                }
                else
                {
                    [soundController stopRecord];
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [soundController invokeDelegate:nil];
                    });
                   
                }
                
                
                
                soundController.isLocked = YES;
                lastHitFrame = durationFrames;
                
            }
        }else{
            
            
//            NSLog(@"durationFrames: %u", (unsigned int)durationFrames);
            
            if(durationFrames > 100 & durationFrames - lastHitFrame >= 25)
            {
                soundController.isLocked = NO;
            }
        }
        
        
        
        
        
    }];
}

-(void)invokeDelegate: (id)info
{
     [[BTMetronomeCoreController getController] startAfter:_globals.currentNoteDuration];
}

@end
