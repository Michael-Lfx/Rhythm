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

//通过蓝牙设备名获得产品型号和具体编号
+(NSString*)getModel:(NSString*)name;
+(NSString*)getSN:(NSString*)name;

@end
