//
//  BTFMCController.h
//  Health
//
//  Created by poppy on 13-8-27.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTFMMoniterController : NSObject

-(double)addFM;
-(void)updateFM:(double) originalTimestamp withNewTimestamp:(double)newTimestamp;
-(void)removeFM: (double) timestamp;
-(void)getFMList:(double)startTimestamp endBy:(double)endTimestamp;

@end
