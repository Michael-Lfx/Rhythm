//
//  BTBandPeripheral.h
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTConstants.h"

@interface BTBandPeripheral : NSObject

@property(strong, nonatomic) NSMutableDictionary* allCharacteristics;
@property(strong, nonatomic) NSMutableDictionary* allValues;
@property(strong, nonatomic) NSMutableDictionary* allCallback;
@property(strong, nonatomic) CBPeripheral* handle;

@property(strong, nonatomic) NSString* name;
@property(assign, nonatomic) int lastSync;
@property(strong, nonatomic) NSNumber* batteryLevel;
@property(assign, nonatomic) Boolean isConnected;
@property(assign, nonatomic) Boolean isFinded;

//同步用
@property(assign, nonatomic) uint16_t dataLength;
@property(assign, nonatomic) uint16_t currentBlock;

//进度条
@property(assign, nonatomic) float dlPercent;

@property(assign, nonatomic) double zero;

-(void)addPeripheral:(CBPeripheral*)peripheral;

@end
