//
//  BTBeat.h
//  SmartBat
//
//  Created by poppy on 13-6-6.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTMeasure.h"

@interface BTSubdivision : NSObject{
    
    NSArray *_noteList;
    
}


@property NSUInteger playIndex;

-(BTSubdivision *) initWithBeat: (NSArray *) _beatDescription;
-(int)count;
-(void)playNote;
-(void)reset;

@end
