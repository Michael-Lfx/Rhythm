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

//central改变状态后的回调
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            //设置nil查找任何设备
            [self scan];
            
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            //关掉蓝牙开关时清零
            self.globals.bleListCount = 0;
            
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

//发现peripheral后的回调
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discover Peripheral: %@", peripheral);
    
    //找到了就停止扫描
//    [central stopScan];
    
    NSLog(@"%@", advertisementData);
    
    //付给私有变量，不然就释放了
    
    [self.p setObject:peripheral forKey:[NSString stringWithFormat:@"%d",peripheral.hash]];
    
//    [central connectPeripheral:peripheral options:nil];
    
//    if (![self.allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]]) {
    
    
//    }
    
//    [central scanForPeripheralsWithServices:nil options:nil];
    
    BTBandPeripheral* find = [[BTBandPeripheral alloc] initWithPeripheral:peripheral];
    find.name = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
    
    [_allPeripherals setObject:find forKey:[NSNumber numberWithInt:peripheral.hash]];
    
    //连接上一个以后增加
    self.globals.bleListCount++;
    
    NSLog(@"%@", _allPeripherals);
}

//连接peripheral后的回调
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Connect Peripheral: %@", peripheral);
    
    
    
    BTBandPeripheral* find = [[BTBandPeripheral alloc] initWithPeripheral:peripheral];
    
    //取出name后，把未连接的peripheral对象清除
    find.name = [[_allPeripherals objectForKey:[NSNumber numberWithInt:peripheral.hash]] name];
    [_allPeripherals removeObjectForKey:[NSNumber numberWithInt:peripheral.hash]];
    
    [self.allPeripherals setObject:find forKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    //代理peripheral
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kMetronomeServiceUUID], [CBUUID UUIDWithString:kBatteryServiceUUID]]];
    
    NSLog(@"%@", _allPeripherals);
}

//发现所有service后的回调
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"DiscoverServices error: %@", error.localizedDescription);
    }
    
    for (CBService *s in peripheral.services) {
        
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//发现所有characteristic后的回调
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
                
                //读取完名称和电量后
                self.globals.bleListCount+=0;
                
            }];
            
            [self sync:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
        }
    }
}

//注册update value后的回调
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

//写数据完成后的回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"WriteValueForCharacteristic error: %@", error.localizedDescription);
    }
//    NSLog(@"write value: %@", characteristic.value);
}

//某个peripheral断开连接
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

//向某个peripheral写数据
-(void)write:(NSData*)value withUUID:(CBUUID*)cuuid fromPeripheral:(CBUUID*)puuid{
    
    BTBandPeripheral* bp = [_allPeripherals objectForKey:puuid];
    CBCharacteristic* tmp = [bp.allCharacteristics objectForKey:cuuid];
    
    [bp.handle writeValue:value forCharacteristic:tmp type:CBCharacteristicWriteWithResponse];
}

//读取某个peripheral里的数据
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

//所有设备播放
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

//所有设备暂停
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

//返回蓝牙列表展示数据
-(NSArray*)bleList:(NSUInteger)index{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    BTBandPeripheral* bp = [[enumeratorValue allObjects] objectAtIndex:index];
    
    //1
    NSString* name = bp.name;
    //0
    NSNumber* isConnected = [NSNumber numberWithBool:bp.handle.isConnected];
    //2
    uint8_t d;
    [[bp.allValues objectForKey:[CBUUID UUIDWithString:kBatteryLevelUUID]] getBytes:&d];
    NSNumber *batteryLevel = [NSNumber numberWithInt:d];
    
    return @[isConnected, name, batteryLevel];
}

//连接选中的peripheral
-(void)connectSelectedPeripheral:(NSUInteger)index{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    BTBandPeripheral* bp = [[enumeratorValue allObjects] objectAtIndex:index];
    
    if (!bp.handle.isConnected) {
        [_cm connectPeripheral:bp.handle options:nil];
    } 
    
}

@end
