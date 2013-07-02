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
        
        self.p = [NSMutableDictionary dictionaryWithCapacity:7];
        
        self.globals = [BTGlobals sharedGlobals];
        
        self.globals.bleListCount = 0;
    }
    
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            //设置nil查找任何设备
            [self scan];
            
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discover Peripheral: %@", peripheral);
    
    //找到了就停止扫描
//    [central stopScan];
    
    NSLog(@"%@", advertisementData);
    
    //付给私有变量，不然就释放了
    
    [self.p setObject:peripheral forKey:[NSString stringWithFormat:@"%d",peripheral.hash]];
    
    [central connectPeripheral:peripheral options:nil];
    
//    if (![self.allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]]) {
    
    
//    }
    
//    [central scanForPeripheralsWithServices:nil options:nil];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Connect Peripheral: %@", peripheral);
    
    BTBandPeripheral* find = [[BTBandPeripheral alloc] initWithPeripheral:peripheral];
    
    [self.allPeripherals setObject:find forKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    //代理peripheral
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"DiscoverServices error: %@", error.localizedDescription);
    }
    
//    NSLog(@"Discover Services: %@", peripheral.services);
    
    for (CBService *s in peripheral.services) {
        
//        NSLog(@"%@", s.UUID);
        
        if ([s.UUID isEqual:[CBUUID UUIDWithString:kMetronomeServiceUUID]] || [s.UUID isEqual:[CBUUID UUIDWithString:kBatteryServiceUUID]]) {
        
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error) {
        NSLog(@"DiscoverCharacteristics error: %@", error.localizedDescription);
    }
    
    NSLog(@"Discover Characteristics sum: %d", service.characteristics.count);
    
    BTBandPeripheral* bp = [_allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    for (CBCharacteristic* c in service.characteristics) {
        
        [bp.allCharacteristics setObject:c forKey:c.UUID];
        
//      [peripheral setNotifyValue:YES forCharacteristic:c];
        
        //连接完成！！
        if(bp.allCharacteristics.count == kCharacteristicsCount){
            NSLog(@"ge zaile ");
            _globals.bleConnected = YES;
            
            [self read:[CBUUID UUIDWithString:kMetronomeNameUUID] fromPeripheral:[CBUUID UUIDWithCFUUID:peripheral.UUID] withBlock:nil];
            
            [self read:[CBUUID UUIDWithString:kBatteryLevelUUID] fromPeripheral:[CBUUID UUIDWithCFUUID:peripheral.UUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
                
                self.globals.bleListCount++;
                
            }];
            
            [self sync:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
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
    
    //把数据放到缓存里
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

//某个p断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    //从缓存中移除
    [_allPeripherals removeObjectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    //设备总数减少
    self.globals.bleListCount--;
    
    //断开连接后自动重新搜索
    [self scan];
}


/*
    对外接口
 */

-(void)write:(NSData*)value withUUID:(CBUUID*)cuuid fromPeripheral:(CBUUID*)puuid{
    
    BTBandPeripheral* bp = [_allPeripherals objectForKey:puuid];
    CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
    
    [bp.handle writeValue:value forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
}

-(void)read:(CBUUID*)cuuid fromPeripheral:(CBUUID*)puuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block{
    
    BTBandPeripheral* bp = [_allPeripherals objectForKey:puuid];
    CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
    
    //把block句柄放到缓存里
    //注意：没有加锁，可能有问题
    if (block) {
        [bp.allCallback setObject:block forKey:cuuid];
    }
    
    [bp.handle readValueForCharacteristic:tmp];
}

//向所有peripheral写数据
-(void)writeAll:(NSData*)value withUUID:(CBUUID*)cuuid{
    
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
        
        if (tmp) {
            [bp.handle writeValue:value forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
        }
    }
}


//读取所有peripheral里某个characteristic
-(void)readAll:(CBUUID*)cuuid withBlock:(void (^)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral))block{
    
    //遍历所有的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        
        //根据uuid找到具体的characteristic
        CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
        
        if (tmp) {
            //把block句柄放到缓存里
            //注意：没有加锁，可能有问题
            if (block) {
                [bp.allCallback setObject:block forKey:cuuid];
            }
            
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
    
    [_cm scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kMetronomeServiceUUID]] options:nil];
    
    NSLog(@"scan ForPeripherals");
}

//和手环同步时间
-(void)sync:(CBUUID*)puuid{
    NSThread *syncTread = [[NSThread alloc] initWithTarget:self selector:@selector(doSync:) object:puuid];
    
    [syncTread start];
}

//同步操作
-(void)doSync:(CBUUID*)puuid{
    //调高优先级
    [NSThread setThreadPriority:1.0];
    
    //取得主线程
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    uint8_t count = 0;
    Boolean isLock = NO;
    double sendTime = 0.0, now = 0.0;
    
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    double syncStart = mach_absolute_time() * 1.0e-9;
    syncStart *= info.numer;
    syncStart /= info.denom;
    
    while (count < kSyncCount) {
        
        while (isLock) {
            now = mach_absolute_time() * 1.0e-9;
            now *= info.numer;
            now /= info.denom;
            
            if (now >= sendTime) {
                isLock = NO;
            }
        }
        
        //让主线程发蓝牙请求
        dispatch_async(mainQueue, ^{
            
            [self write:[NSData dataWithBytes:&count length:sizeof(count)] withUUID:[CBUUID UUIDWithString:kMetronomeSyncUUID] fromPeripheral:puuid];
        });
        
        //计算序号
        count++;
        isLock = YES;
        
        sendTime = syncStart + kSyncInterval * count;
        
        now = mach_absolute_time() * 1.0e-9;
        now *= info.numer;
        now /= info.denom;
        
        //缩短sleep时间，提前用死循环加锁
        [NSThread sleepForTimeInterval:sendTime - now - LOCK_TIME];
    }
    
    //最后读取蓝牙里算出的最匹配时间点
    [self read:[CBUUID UUIDWithString:kMetronomeZeroUUID] fromPeripheral:puuid withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
        
        uint8_t sn;
        [value getBytes:&sn];
        
        NSLog(@"cb: %d", sn);
        
        BTBandPeripheral *bp = [_allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
        
        bp.zero = syncStart + kSyncInterval * sn;
        
        NSLog(@"zero is: %f", bp.zero);
        
        //如果设备正在播放，就等马上启动
        if ([[self.globals.systemStatus valueForKey:@"playStatus"] boolValue]){
            NSLog(@"wait for restart");
            
            self.globals.waitForRestart = YES;
        }
    }];
}

-(void)playAllAt:(double)timestamp{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        if (bp.play == 0) {
            bp.play = 1;
        
            CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:[CBUUID UUIDWithString:kMetronomePlayUUID]];
        
            uint32_t start = (timestamp - bp.zero) * 1000000;
            
            NSLog(@"let's play : %d", start);
        
            if (tmp) {
                [bp.handle writeValue:[NSData dataWithBytes:&start length:sizeof(start)] forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

-(void)pauseAll{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        if (bp.play == 1) {
            bp.play = 0;
            
            CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:[CBUUID UUIDWithString:kMetronomePlayUUID]];
            
            NSLog(@"let's pause");
            
            uint8_t rs = bp.play;
            
            if (tmp) {
                [bp.handle writeValue:[NSData dataWithBytes:&rs length:sizeof(rs)] forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

-(NSArray*)bleList:(NSUInteger)index{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    BTBandPeripheral* bp = [[enumeratorValue allObjects] objectAtIndex:index];
    
    NSLog(@"index : %@", bp);
    
    //1
    NSString* name = [[NSString alloc] initWithData:[bp.allValues objectForKey:[CBUUID UUIDWithString:kMetronomeNameUUID]] encoding:NSUTF8StringEncoding];
    //0
    Boolean isConnected = bp.handle.isConnected;
    //2
    uint8_t batteryLevel;
    [[bp.allValues objectForKey:[CBUUID UUIDWithString:kBatteryLevelUUID]] getBytes:&batteryLevel];
    
    return [NSArray arrayWithObjects:[NSNumber numberWithBool:isConnected], name, [NSNumber numberWithInt:batteryLevel], nil];
}

@end
