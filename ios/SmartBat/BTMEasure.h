//
//  BTMEasure.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTBeat.h"


@interface BTMeasure : NSObject{
    
    NSArray *_noteList;
    int _playIndex;
    
}

@property int playIndex;
@property double noteType;

-(BTMeasure *) initWithBeat: (NSArray *) _beatDescription andNoteType:(double)noteType;
-(void)playNote;
-(NSArray *)getNoteList;
-(int)getNoteCount;
-(BTBeat *)getNote:(int)index;
-(BTBeat *)getCurrentNote;
-(void)reset;

@end