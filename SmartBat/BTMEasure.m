//
//  BTMEasure.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMeasure.h"

@implementation BTMeasure

@synthesize note, beat;

-(BTMeasure *) initWithBeatAndNote: (NSUInteger) beat withNote:(NSUInteger) note
{
    
    self = [super init];
    
    [self setBeat:beat];
    [self setNote:note];
    
    return self;
}

@end
