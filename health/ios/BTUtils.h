//
//  BTUtils.h
//  Health
//
//  Created by kaka' on 13-10-14.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTUtils : NSObject

+(uint32_t)currentSeconds;
+(NSDate*)dateWithSeconds:(NSTimeInterval)seconds;

+(int)getYear:(NSTimeInterval)seconds;
+(int)getMonth:(NSTimeInterval)seconds;
+(int)getDay:(NSTimeInterval)seconds;
+(int)getHour:(NSTimeInterval)seconds;
+(int)getMinutes:(NSTimeInterval)seconds;

@end
