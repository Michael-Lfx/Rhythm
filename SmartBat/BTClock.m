//
//  BTClock.m
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTClock.h"

#define kMaxBPM 225
#define kMinBPM 1
#define kDefaultBPM 120

@implementation BTClock

-(id)init
{
    self = [super init];
        
    [self setBpm:kDefaultBPM];
    
    return self;
}


- (void)startDriverTimer:(id)info {
    
    // Give the sound thread high priority to keep the timing steady.
    [NSThread setThreadPriority:1.0];
    BOOL continuePlaying = YES;
    
    while (continuePlaying) {
        
        [self.delegate beatOnHandler:1];
        
        
        NSDate *curtainTime = [[NSDate alloc] initWithTimeIntervalSinceNow:_duration];
        NSDate *currentTime = [[NSDate alloc] init];
        
        // Wake up periodically to see if we've been cancelled.
        while (continuePlaying && ([currentTime compare:curtainTime] != NSOrderedDescending)) {
            if ([_soundPlayerThread isCancelled] == YES) {
                continuePlaying = NO;
            }
            [NSThread sleepForTimeInterval:0.01];
            currentTime = [[NSDate alloc] init];
        }
    }
}

- (void)waitForSoundDriverThreadToFinish {
    while (_soundPlayerThread && ![_soundPlayerThread isFinished]) { // Wait for the thread to finish.
        [NSThread sleepForTimeInterval:0.1];
    }
}


- (void)startDriverThread {
    if (_soundPlayerThread != nil) {
        [_soundPlayerThread cancel];
        [self waitForSoundDriverThreadToFinish];
    }
    
    NSThread *driverThread = [[NSThread alloc] initWithTarget:self selector:@selector(startDriverTimer:) object:nil];
    _soundPlayerThread = driverThread;
    
    [_soundPlayerThread start];
}


- (void)stopDriverThread {
    [_soundPlayerThread cancel];
    [self waitForSoundDriverThreadToFinish];
    _soundPlayerThread = nil;
}

- (NSUInteger)bpm {
    return lrint(ceil(60.0 / (_duration)));
}


- (void)setBpm:(NSUInteger)bpm {
    if (bpm >= kMaxBPM) {
        bpm = kMaxBPM;
    } else if (bpm <= kMinBPM) {
        bpm = kMinBPM;
    }
    _duration = (60.0 / bpm);
}

@end
