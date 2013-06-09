//
//  BTMEasure.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTBeat.h"

@interface BTMeasure : NSObject

@property int beat;
@property double note;

-(BTMeasure *) initWithBeat: (int) beat andNote:(double) note;

@end