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
@property(assign, nonatomic) double zero;

@property(assign, nonatomic) uint8_t play;
//@property(assign, nonatomic) Boolean waitForRestart;

-(BTBandPeripheral*)initWithPeripheral:(CBPeripheral*)peripheral;

@end
