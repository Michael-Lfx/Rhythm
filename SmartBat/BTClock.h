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
    CGFloat duration;
    NSUInteger beatNumber;
    BOOL tempoChangeInProgress;
    NSThread *soundPlayerThread;
    id<BeatOnDelegate> delegate;

}

@property (nonatomic, retain) id<BeatOnDelegate> delegate;

@property NSUInteger bpm;
@property CGFloat duration;
@property (nonatomic, retain) NSThread *soundPlayerThread;
-(void)startDriverThread;
-(void)stopDriverThread;

@end
