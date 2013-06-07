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

- (void)startLoopWithTimeInterval:(NSTimeInterval) timeInterval
{
    if(_timeLineThread)
    {
        return;
    }
    
    _isStop = false;
    
    
    NSNumber * number = [[NSNumber alloc]initWithDouble:timeInterval];
    
    _timeLineThread = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:number];
    [_timeLineThread start];
    
}

- (void)stopLoop
{
    _isStop = true;
    
    [_timeLineThread cancel];
    _timeLineThread = nil;
    
}

-(void)updateSleepInterval:(NSTimeInterval) sleepInterval
{
    self.interval  = sleepInterval;
}


-(void) loop:(NSNumber *) timeIntervalNumber
{
    
    if(timeIntervalNumber){
        self.interval = [timeIntervalNumber doubleValue];
    }
    
    while (!_isStop) {
        
        _previousTime = [[NSDate date] timeIntervalSince1970];
        
        NSLog(@"%f", _previousTime);
        
        [NSThread setThreadPriority:1.0];
        
        [self performSelectorOnMainThread:@selector(invokeDelegate:) withObject:nil waitUntilDone:YES];
        
        [NSThread sleepForTimeInterval: self.interval];
        
        
    }
}



-(void)invokeDelegate:(id)info
{
    [self.timeLineDelegate onTimeInvokeHandler:[NSDate date]];
}




@end
