//
//  BTBeat.m
//  SmartBat
//
//  Created by poppy on 13-6-13.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBeat.h"

@implementation BTBeat

@synthesize indexOfMeasure, indexOfSubdivision, beatType, hitTime;

-(BTBeat *) initWithBeatType:(BTBeatType) _beatType
{
    self = [super init];
    
    self.beatType = _beatType;
    self.indexOfMeasure = 0;
    self.indexOfSubdivision = 0;
    
    return self;
}

@end
