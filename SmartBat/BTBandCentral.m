 //
//  BTBandCentral.m
//  SmartBat
//
//  Created by kaka' on 13-6-15.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBandCentral.h"

@implementation BTBandCentral

-(id)init{
    self = [super init];
    
    if (self) {
        self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.allPeripherals = [NSMutableDictionary dictionaryWithCapacity:7];
        
        self.globals = [BTGlobals sharedGlobals];
    }
    
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            //设置nil查找任何设备
            [central scanForPeripheralsWithServices:nil options:nil];
            
            NSLog(@"scan ForPeripherals");
            
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discover Peripheral: %@", [CBUUID UUIDWithCFUUID:peripheral.UUID]);
    
    //找到了就停止扫描
    [central stopScan];
    
    //付给私有变量，不然就释放了
    BTBandPeripheral* find = [[BTBandPeripheral alloc] initWithPeripheral:peripheral];
    [self.allPeripherals setObject:find forKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
//    self.p = peripheral;
    
    [central connectPeripheral:peripheral options:nil];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Connect Peripheral: %@", peripheral);
    
    //代理peripheral
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"DiscoverServices error: %@", error.localizedDescription);
    }
    
    NSLog(@"Discover Services: %@", peripheral.services);
    
    for (CBService *s in peripheral.services) {
        
        NSLog(@"%@", s.UUID);
        
        if ([s.UUID isEqual:[CBUUID UUIDWithString:kMetronomeServiceUUID]] || [s.UUID isEqual:[CBUUID UUIDWithString:kBatteryServiceUUID]]) {
//            NSLog(@"find target");
        
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error) {
        NSLog(@"DiscoverCharacteristics error: %@", error.localizedDescription);
    }
    
    NSLog(@"Discover Characteristics");
    
    for (CBCharacteristic* c in service.characteristics) {
        
        BTBandPeripheral* bp = [_allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
        
        [bp.allCharacteristics setObject:c forKey:c.UUID];
        
//      [peripheral setNotifyValue:YES forCharacteristic:c];
//        [peripheral readValueForCharacteristic:c];
        
        NSLog(@"%lu", (unsigned long)bp.allCharacteristics.count);
        
        if(bp.allCharacteristics.count == kCharacteristicsCount){
            NSLog(@"ge zaile ");
            _globals.bluetoothConnected = YES;
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"UpdateNotificationStateForCharacteristic erroe:%@", error.localizedDescription);
    }
    
    NSLog(@"%hhd", characteristic.isNotifying);
    
    if (characteristic.isNotifying) {
        
        NSLog(@"Notification began on %@", characteristic);
        
        [peripheral readValueForCharacteristic:characteristic];

    } else{
        NSLog(@"Notification stop %@", characteristic);
    }
}

//收到周边设备的数据更新
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"UpdateValueForCharacteristic error: %@", error.localizedDescription);
    }
    
    //根据uuid取到对象
    BTBandPeripheral* bp = [_allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    
    [bp.allValues setObject:characteristic.value forKey:characteristic.UUID];
    
    NSLog(@"%@", characteristic.UUID);
    
    void (^block)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral)  = [bp.allCallback objectForKey:characteristic.UUID];
    
    if (block) {
        block(characteristic.value, characteristic, peripheral);
        [bp.allCallback removeObjectForKey:characteristic.UUID];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"WriteValueForCharacteristic error: %@", error.localizedDescription);
    }
    NSLog(@"write value: %@", characteristic.value);
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //断开连接后自动重新搜索
    [central scanForPeripheralsWithServices:nil options:nil];
}


/*
    对外接口
 */

-(void)write:(NSData*)value withUUID:(CBUUID*)cuuid FromPeripheral:(CBUUID*)puuid{
    BTBandPeripheral* bp = [_allPeripherals objectForKey:puuid];
    
    CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
    
    [bp.handle writeValue:value forCharacteristic:tmp type:CBCharacteristicWriteWithoutResponse];
}

//向所有peripheral写数据
-(void)writeAll:(NSData*)value withUUID:(CBUUID*)cuuid{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
        
        if (bp.handle) {
            [bp.handle writeValue:value forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
        }
    }
}


//读取所有peripheral里某个characteristic
-(void)readAll:(CBUUID*)uuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block{
    
    //遍历所有的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        
        //根据uuid找到具体的characteristic
        CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:uuid];
        
        if (bp.handle) {
            //把block句柄放到缓存里
            //注意：没有加锁，可能有问题
            [bp.allCallback setObject:block forKey:uuid];
            
            //发送read请求
            [bp.handle readValueForCharacteristic:tmp];
        }
    }
}


//把丫做成单例
+(BTBandCentral *)sharedBandCentral
{
    static BTBandCentral *sharedBandCentralInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedBandCentralInstance = [[self alloc] init];
    });
    return sharedBandCentralInstance;
}

//主动重新搜索
-(void)scan{
    [_cm scanForPeripheralsWithServices:nil options:nil];
}

-(void)setDuration:(double)duration{
    
}

@end
