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
    _isStop = true;
    return self;
}

- (void)startLoop
{
    _isStop = false;
    
    _timeLineThread = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:nil];
    [_timeLineThread start];
    
}

- (void)stopLoop
{
    _isStop = true;
    
    [_timeLineThread cancel];
    _timeLineThread = nil;
    
}


-(void) loop:(id) info
{
    while (!_isStop) {
        
        [NSThread setThreadPriority:1.0];
        
        [self performSelectorOnMainThread:@selector(invokeDelegate:) withObject:nil waitUntilDone:YES];

        [NSThread sleepForTimeInterval: DEFAULT_INTERVAL];
    
    }
}



-(void)invokeDelegate:(id)info
{
    [self.timeLineDelegate onTimeInvokeHandler:[NSDate date]];
}




@end
