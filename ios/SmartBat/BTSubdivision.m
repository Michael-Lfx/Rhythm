//
//  BTBeat.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSubdivision.h"

@implementation BTSubdivision


-(BTSubdivision *) initWithBeat: (NSArray *) _beatDescription
{
    self = [super init];
    
    _noteList = [[NSArray alloc]initWithArray:_beatDescription];

    self.playIndex = 0;
    
    return self;

}

-(int)count
{
    return [_noteList count];
}

-(void) playNote
{
    if(self.playIndex == [_noteList count]-1){
        
        self.playIndex = 0;
    }
    else
    {
        self.playIndex ++;
    }
}

-(void)reset
{
    self.playIndex = 0;
}

-(BTBeatType)getNote: (int)index
{
    
    BTBeatType type = [[_noteList objectAtIndex:index] intValue];
    
    return type;
}

@end
