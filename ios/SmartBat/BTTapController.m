//
//  BTTapController.m
//  SmartBat
//
//  Created by poppy on 13-6-21.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTapController.h"

@implementation BTTapController

-(id)init
{
    self = [super init];
    
    [self reset];
    
    _globals = [BTGlobals sharedGlobals];
    
    
    [_globals addObserver:self forKeyPath:@"systemStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    return self;
}


+(BTTapController *)sharedInstance
{
    static BTTapController *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)updateTargetCount:(int)targetCount
{
    _targetCount = targetCount;
}

-(int)tap
{
    
    NSLog(@"tap!");
    NSNumber *now = [[NSNumber alloc]initWithDouble:[self getMachNowTime]];
    [_hitPointArray addObject:now];
    
    
    if([_hitPointArray count] == _targetCount)
    {
        [self processTapBPM];
        [self reset];
    }
    
    return [self currentTapCount];
}

-(int)currentTapCount
{
    return [_hitPointArray count];
}

-(int)targetTapCount
{
    return _targetCount;
}

-(void)reset
{
    _hitPointArray = [[NSMutableArray alloc]init];
    
}

-(void)processTapBPM
{
   
    
    double duration = 0.0;
    
    for(int n=1; n<[_hitPointArray count]; n++)
    {
        duration += [[_hitPointArray objectAtIndex:n]doubleValue] - [[_hitPointArray objectAtIndex:n-1]doubleValue];
    }
    
    int bpm = 60 / (duration / ([_hitPointArray count] - 1)) ;
    
    if(bpm > BPM_MAX)
    {
        bpm = BPM_MAX;
    }
    
    if(bpm < BPM_MIN)
    {
        bpm = BPM_MIN;
    }
    
    _globals.beatPerMinute = bpm;
    
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


//监控参数，更新显示
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
        
    if([keyPath isEqualToString:@"systemStatus"])
    {
        if(![[_globals.systemStatus valueForKey:@"playStatus"] boolValue])
        {
            [self reset];
        }
    }
}




@end
