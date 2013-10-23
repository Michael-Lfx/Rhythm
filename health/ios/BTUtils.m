//
//  BTUtils.m
//  Health
//
//  Created by kaka' on 13-10-14.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTUtils.h"

#define SECONDS_2000_1970   946684800

@implementation BTUtils

+(uint32_t)currentSeconds{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    // 跟手机设置同一个时区
    // 以后如果加表功能，没有坑
    [df setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate* date2000 = [df dateFromString:@"2000/01/01 00:00:00"];
    return (uint32_t)[[NSDate date] timeIntervalSinceDate:date2000];
}

+(NSDate*)dateWithSeconds:(NSTimeInterval)seconds{
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(seconds + SECONDS_2000_1970)];
}

+(NSNumber*)getDateFormat:(NSDate*)date with:(NSString*)formatter{
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:formatter];
    
    // 初始化手环时间时已经转成当地时间
    // 这里设置成格林威治时间
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    return [NSNumber numberWithInt:[[df stringFromDate:date] intValue]];
}

+(NSNumber*)getYear:(NSDate*)date{
    return [self getDateFormat:date with:@"yyyy"];
}

+(NSNumber*)getMonth:(NSDate*)date{
    return [self getDateFormat:date with:@"MM"];
}

+(NSNumber*)getDay:(NSDate*)date{
    return [self getDateFormat:date with:@"dd"];
}

+(NSNumber*)getHour:(NSDate*)date{
    return [self getDateFormat:date with:@"HH"];
}

+(NSNumber*)getMinutes:(NSDate*)date{
    return [self getDateFormat:date with:@"mm"];
}

@end
