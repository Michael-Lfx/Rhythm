//
//  BTBeat.m
//  SmartBat
//
//  Created by poppy on 13-6-13.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBeat.h"

@implementation BTBeat

-(BTBeat *) initWithBeatType:(BTBeatType) beatType
{
    self = [super init];
    
    self.beatType = beatType;
    self.indexOfMeasure = 0;
    self.indexOfSubdivision = 0;
    
    return self;
}

@end
