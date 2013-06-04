//
//  BTConfigs.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTConfigs.h"

@implementation BTConfigs

@synthesize swipe2MoveTimes = _swipe2MoveTimes;
@synthesize threshold2Complete = _threshold2Complete;
@synthesize threshold2CompleteDuration = _threshold2CompleteDuration;
@synthesize commonViewCtl = _commonViewCtl;

-(BTConfigs*)init{
    self = [super init];
    
    if (self) {
        _swipe2MoveTimes = 1.2f;
        _threshold2Complete = 0.3f;
        _threshold2CompleteDuration = 0.2f;
    }
    
    return self;
}

+(BTConfigs *)sharedConfigs
{
    static BTConfigs *sharedConfigsInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedConfigsInstance = [[self alloc] init];
        });
    return sharedConfigsInstance;
}

@end
