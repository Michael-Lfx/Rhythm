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
#import "BTConstants.h"

@interface BTGlobals : NSObject{
    NSManagedObjectContext* _context;
    BTEntity* _globalsInEntity;
}

//这里是全局变量

@property(assign, nonatomic) int lastCheckVersionDate;
@property(assign, nonatomic) int installDate;
@property(assign, nonatomic) int hasAskGrade;
@property(assign, nonatomic) int lastSync;

//手环总数和数组
@property(assign, nonatomic) NSInteger bleListCount;
@property(strong, nonatomic) NSMutableDictionary* allPeripherals;

//手机是否连接设备
@property(assign, nonatomic) Boolean isConnectedBLE;

//进度条
@property(assign, nonatomic) float dlPercent;

//数据缓存
@property(strong, nonatomic) NSMutableArray* dataList;
@property(assign, nonatomic) NSInteger dataListCount;


+(BTGlobals*)sharedGlobals;
-(void)applicationWillResignActive:(NSNotification*) notification;

@end
