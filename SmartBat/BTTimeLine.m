//
//  BTTimeLine.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTimeLine.h"

@implementation BTTimeLine

@synthesize interval;

-(id)init
{
    self = [super init];
    
    self.interval = DEFAULT_INTERVAL;
    _isStop = true;
    
    return self;
}

- (double)startLoopWithDuration:(NSTimeInterval) duration
{
    if(_timeLineThread)
    {
        return 0;
    }
    
    _isStop = false;
    _clockTickCount = 0;
    _clockDuration = duration;
    
    
    NSNumber * number = [[NSNumber alloc]initWithDouble:duration];
    
    _timeLineThread = [[NSThread alloc] initWithTarget:self selector:@selector(loop:) object:number];
    [_timeLineThread start];
    
    _clockStartTime = [self getMachNowTime];
    return _clockStartTime;
    
}

- (double)stopLoop
{
    _isStop = true;
    
    [_timeLineThread cancel];
    _timeLineThread = nil;
    _clockStartTime = 0;
    _clockPreviousTickTime = 0;
    
    
    return [self getMachNowTime];
    
}

-(void)updateClockDuration:(NSTimeInterval) clockDuration
{
    _clockDuration = clockDuration;
    _clockTickCount = 0;
    _clockStartTime = 0;

}


-(double)getMachNowTime
{
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    double nowTime =  mach_absolute_time() * 1.0e-9;
        nowTime *= info.numer;
        nowTime /= info.denom;
    
    return nowTime;
}

-(void) loop:(NSNumber *) timeIntervalNumber
{
    
    if(timeIntervalNumber){
        
        self.interval = [timeIntervalNumber doubleValue];
    }
    
    [NSThread setThreadPriority:1.0];
    
    while (!_isStop) {
                
       
        
        _clockPreviousTickTime = [self getMachNowTime];
        
        if(!_clockStartTime)
        {
            _clockStartTime =_clockPreviousTickTime;
        }
        
        
        Boolean _isLock = true;
        
        while(_isLock)
        {
            NSTimeInterval _testTime = [self getMachNowTime];
            
            if(_testTime >= _clockStartTime + _clockDuration * _clockTickCount  )
            {
                _isLock = false;
            }
            else
            {
//                NSLog(@"d: %f, testTime: %f, clockStartTime: %f, clockDuration: %f, clockTickCount: %d",_testTime -( _clockStartTime + _clockDuration * _clockTickCount ), _testTime, _clockStartTime, _clockDuration, _clockTickCount );
            }
        }
        
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self invokeDelegate:nil];
        });
        
        
        
        NSTimeInterval _accurateClockDuration = floor((_clockDuration + ( _clockStartTime + _clockDuration * _clockTickCount - _clockPreviousTickTime))*1.0e3)/1.0e3;
        
        
        
//        NSLog(@"accurateClock: %.12f", _accurateClockDuration);
        
        _clockTickCount++;
        
        [NSThread sleepForTimeInterval: _accurateClockDuration - LOCK_TIME];
        
        
    }
}



-(void)invokeDelegate:(id)info
{
    mach_timebase_info_data_t data;
    mach_timebase_info(&data);
    
    NSTimeInterval _point = [self getMachNowTime];
    
    
    [self.timeLineDelegate onTimeInvokeHandler: _point];
}




@end
