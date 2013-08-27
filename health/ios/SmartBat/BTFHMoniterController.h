//
//  BTFHMoniterController.h
//  Health
//
//  Created by poppy on 13-8-27.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTFHRecord.h"

@interface BTFHMoniterController : NSObject
{

}

@property(nonatomic, retain) BTFHRecord * currentRecord;

-(double)startRecord;
-(double)stopRecord;
-(double)addFH;
-(BTFHRecord *)getRecord:(int)index;
-(void)removeRecord:(int)index;
-(NSArray *)getRecordList:(double)startTimestamp endBy:(double)stopTimestamp;

@end
