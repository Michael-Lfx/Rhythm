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

-(BTMeasure *) initWithBeat: (int) _beat andNote:(double) _note
{
    
    self = [super init];
    
    self.beat = _beat;
    self.note = _note;
    
    return self;
}

@end
