//
//  BTConfigs.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTGlobals.h"

@implementation BTGlobals

@synthesize bitPerMinute;

-(BTGlobals*)init{
    self = [super init];
    
    if (self) {
        bitPerMinute = 150;
    }
    
    return self;
}

+(BTGlobals *)sharedGlobals
{
    static BTGlobals *sharedGlobalsInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedGlobalsInstance = [[self alloc] init];
        });
    return sharedGlobalsInstance;
}

@end
