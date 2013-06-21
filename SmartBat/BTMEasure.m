//
//  BTMEasure.m
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMeasure.h"

@implementation BTMeasure

@synthesize noteType;

-(BTMeasure *) initWithBeat: (NSArray *) _beatDescription andNoteType:(double) _noteType
{
    
    self = [super init];
    
    _noteList = [[NSArray alloc]initWithArray:_beatDescription];
    
    self.playIndex = 0;
    self.noteType = _noteType;
    
    return self;
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


-(BTBeat *) getCurrentNote
{
    return [self getNote:self.playIndex];
}

-(void)reset
{
    self.playIndex = 0;
}

-(BTBeat *)getNote: (int)index
{
    
    BTBeat * note = [_noteList objectAtIndex:index];
    
    return note;
}

-(int)getNoteCount
{
    return [_noteList count];
}

-(void) updateBeat:(int) _beat withNote:(double) _note;
{
    
}

@end
