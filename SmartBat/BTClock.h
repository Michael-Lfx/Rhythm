//
//  BTClock.h
//  SmartBat
//
//  Created by poppy on 13-6-5.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@protocol BeatOnDelegate
-(void)beatOnHandler:(int)beatCount;
@end


@interface BTClock : NSObject
{
    CGFloat _duration;
    NSUInteger _beatNumber;
    BOOL _tempoChangeInProgress;
    NSThread *_soundPlayerThread;

}

@property (nonatomic, retain) id<BeatOnDelegate> delegate;
@property NSUInteger bpm;

-(void)startDriverThread;
-(void)stopDriverThread;

@end
