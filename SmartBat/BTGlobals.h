//
//  BTConfigs.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTGlobals : NSObject

@property(assign, nonatomic) int bitPerMinute;

+(BTGlobals*)sharedGlobals;

@end
