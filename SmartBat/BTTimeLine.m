//
//  BTTimeLine.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeLine.h"

#define DEFAULT_INTERVAL 0.01

@implementation BTTimeLine

@synthesize interval;

-(id)init
{
    self = [super init];
    
    self.interval = DEFAULT_INTERVAL;
    _isStop = true;
    
    return self;
}

- (void)startLoopWithDuration:(NSTimeInterval) duration
{
    if(_timeLineThread)
    {
        return;
    }
    
    _isStop = false;
    _clockTickCount = 0;
    _clockDuration = duration;
    
    
    NSNumber * number = [[NSNumber alloc]initWithDouble:duration];
    
    _timeLineThread = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:number];
    [_timeLineThread start];
    
}

- (void)stopLoop
{
    _isStop = true;
    
    [_timeLineThread cancel];
    _timeLineThread = nil;
    _clockStartTime = 0;
    _clockPreviousTickTime = 0;
    
}

-(void)updateClockDuration:(NSTimeInterval) clockDuration
{
    _clockDuration = clockDuration;
    _clockTickCount = 0;
    _clockStartTime = 0;
}


-(void) loop:(NSNumber *) timeIntervalNumber
{
    
    if(timeIntervalNumber){
        
        self.interval = [timeIntervalNumber doubleValue];
    }
    
    [NSThread setThreadPriority:1.0];
    
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    while (!_isStop) {
                
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self invokeDelegate:nil];
            });
        
        _clockPreviousTickTime = mach_absolute_time() * 1.0e-9;
        _clockPreviousTickTime *= info.numer;
        _clockPreviousTickTime /= info.denom;
        
        if(!_clockStartTime)
        {
            _clockStartTime = _clockPreviousTickTime;
        }
        
        
        
        NSTimeInterval _accurateClockDuration = _clockDuration + ( _clockStartTime + _clockDuration * _clockTickCount - _clockPreviousTickTime);
        
//        _accurateClockDuration *= info.numer;
//        _accurateClockDuration /= info.denom;
        
//        _accurateClockDuration = _clockDuration;
        
        NSLog(@"accurateClock: %f, info.numer: %u, info.denom: %u", _accurateClockDuration, info.numer, info.denom);
        
        _clockTickCount++;
        
        [NSThread sleepForTimeInterval: _accurateClockDuration];
        
        
    }
}



-(void)invokeDelegate:(id)info
{
    
    [self.timeLineDelegate onTimeInvokeHandler: mach_absolute_time()];
}




@end
