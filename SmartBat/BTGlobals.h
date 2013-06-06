//
//  BTConfigs.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTAppDelegate.h"
#import "BTEntity.h"

@interface BTGlobals : NSObject{
    NSManagedObjectContext* _context;
    BTEntity* _globalsInEntity;
}

@property(assign, nonatomic) NSInteger beatPerMinute;

+(BTGlobals*)sharedGlobals;
-(void)applicationWillResignActive:(NSNotification*) notification;

@end
