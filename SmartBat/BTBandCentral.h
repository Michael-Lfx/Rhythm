//
//  BTBandCentral.h
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTConstants.h"
#import "BTBandPeripheral.h"

@interface BTBandCentral : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(strong, nonatomic) CBCentralManager* cm;
@property(strong, nonatomic) CBPeripheral* p;
@property(strong, nonatomic) CBCharacteristic* c;
@property(assign, nonatomic) int16_t i;

@property(strong, nonatomic) NSMutableDictionary* allPeripherals;

+(BTBandCentral*)sharedBandCentral;

-(void)write:(NSData*)value withUUID:(CBUUID*)cuuid FromPeripheral:(CBUUID*)puuid;
-(void)writeAll:(NSData*)value withUUID:(CBUUID*)cuuid;

-(void)readAll:(CBUUID*)uuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block;

-(void)scan;
-(void)setDuration:(NSTimeInterval) duration;

@end
 