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

+(NSNumber*)getYear:(NSDate*)date;
+(NSNumber*)getMonth:(NSDate*)date;
+(NSNumber*)getDay:(NSDate*)date;
+(NSNumber*)getHour:(NSDate*)date;
+(NSNumber*)getMinutes:(NSDate*)date;

@end
