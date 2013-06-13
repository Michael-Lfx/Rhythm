//
//  BTBeat.h
//  SmartBat
//
//  Created by poppy on 13-6-13.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum BTBeatType : NSUInteger {
    
    BTBeatType_F = 100,
    BTBeatType_P = 101,
    BTBeatType_SUBDIVISION = 102,
    BTBeatType_NIL = -1,
    BTBeatType_1 = 1,
    BTBeatType_2 = 2,
    BTBeatType_3 = 3,
    BTBeatType_4 = 4,
    BTBeatType_5 = 5,
    BTBeatType_6 = 6,
    BTBeatType_7 = 7,
    BTBeatType_8 = 8,
    BTBeatType_9 = 9,
    BTBeatType_10 = 10,
    BTBeatType_11 = 11,
    BTBeatType_12 = 12,
    BTBeatType_13 = 13,
    BTBeatType_14 = 14,
    BTBeatType_15 = 15,
    BTBeatType_16 = 16
} BTBeatType;

@interface BTBeat : NSObject

@property BTBeatType beatType;
@property int indexOfMeasure;
@property int indexOfSubdivision;

-(BTBeat *)initWithBeatType:(BTBeatType) beatType ;

@end
