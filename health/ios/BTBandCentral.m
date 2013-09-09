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
        self.setupBand = nil;
        
        //获取上下文
        UIApplication *app = [UIApplication sharedApplication];
        BTAppDelegate *delegate = (BTAppDelegate *)[app delegate];
        _context = delegate.managedObjectContext;
        
        [self.globals addObserver:self forKeyPath:@"bleShock" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [self.globals addObserver:self forKeyPath:@"bleSpark" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
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
            self.globals.isConnectedBLE = NO;
            
            [_allPeripherals removeAllObjects];
            
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

//发现peripheral后的回调
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discover Peripheral: %@", peripheral);
    NSLog(@"AD count:%lu", (unsigned long)advertisementData.count);
    
    //找到了就停止扫描
//    [central stopScan];
    
    if (advertisementData.count) {
        //付给私有变量，不然就释放了
        //以peripheral的hash为key，存起来
        //    [self.p setObject:peripheral forKey:[NSString stringWithFormat:@"%d",peripheral.hash]];
        
        NSLog(@"AD:%@", advertisementData);
        
        BTBandPeripheral* find = [[BTBandPeripheral alloc] initWithPeripheral:peripheral];
        find.name = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
        
        if (find.name == nil) {
            find.name = @"";
        }
//        find.name = peripheral.name;
        
        [_allPeripherals setObject:find forKey:[NSNumber numberWithInt:peripheral.hash]];
        
        //连接上一个以后增加
        self.globals.bleListCount++;
        
        if ([find.name isEqual:[[NSString alloc] initWithData:_setupName encoding:NSASCIIStringEncoding]]) {
            NSLog(@"find me");
            
            [_cm connectPeripheral:peripheral options:nil];
        }else{
            //查找之前是否连接过
            //读取BTEntity下的数据
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTBleList" inManagedObjectContext:_context];
            
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            
            NSError* error;
            _localBleLIst = [_context executeFetchRequest:request error:&error];
            
            for (BTBleList* old in _localBleLIst) {
                if ([old.name isEqualToString:find.name]){
                    [_cm connectPeripheral:peripheral options:nil];
                }
            }
        }
        
        
        NSLog(@"%@", _localBleLIst);
        
        NSLog(@"%@", _allPeripherals);
    }
}

//连接peripheral后的回调
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Connect Peripheral: %@", peripheral);
    
    BTBandPeripheral* find = [[BTBandPeripheral alloc] initWithPeripheral:peripheral];
    
    //取出name后，把未连接的peripheral对象清除
    find.name = [[_allPeripherals objectForKey:[NSNumber numberWithInt:peripheral.hash]] name];
    [_allPeripherals removeObjectForKey:[NSNumber numberWithInt:peripheral.hash]];
    
    [self.allPeripherals setObject:find forKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    //查找之前是否连接过
    Boolean never = YES;
    
    for (BTBleList* old in _localBleLIst) {
        if ([old.name isEqualToString:find.name]) {
            never = NO;
        }
    }
    
    //从来没有连接过
    if (never && ![find.name isEqual: @"YUE"]) {
        //新建一条记录
        BTBleList* first = [NSEntityDescription insertNewObjectForEntityForName:@"BTBleList" inManagedObjectContext:_context];
        
        first.name = find.name;
        first.uuid = (__bridge NSString *)(CFUUIDCreateString(NULL,peripheral.UUID));
        
        //及时保存
        NSError* error;
        if(![_context save:&error]){
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    
    
    //代理peripheral
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UUID_HEALTH_SERVICE]]];
    
    NSLog(@"hello：%@", _allPeripherals);
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
    
    if (_setupBand != nil && [peripheral isEqual:_setupBand.handle]) {
        
        //初始化手环操作
        NSLog(@"find a new band!!!");
        
        for (CBCharacteristic* c in service.characteristics) {
            if ([c.UUID isEqual:[CBUUID UUIDWithString:UUID_CUSTORM_NAME]]) {
                
                NSLog(@"right");
                
                [peripheral writeValue:_setupName forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            }
        }
        
    }else{
        
        //正常连接操作
        
        BTBandPeripheral* bp = [_allPeripherals objectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
        
        for (CBCharacteristic* c in service.characteristics) {
            
            [bp.allCharacteristics setObject:c forKey:c.UUID];
            
            //连接完成！！
            if(bp.allCharacteristics.count == CHARACTERISTICS_COUNT){
                NSLog(@"ge zaile ");
                
                //开始设备同步
//                [self sync:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
                
                //检查之前是否定位过零点
                [self read:[CBUUID UUIDWithString:UUID_ZERO] fromPeripheral:[CBUUID UUIDWithCFUUID:peripheral.UUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
                    
                    NSLog(@"ZERO IS: %@", value);
                    
                    int16_t z;
                    
                    [value getBytes:&z];
                    
                    NSLog(@"%d", z);
                    
                    if (z == 0) {
                        NSLog(@"wo ca");
                        
                        uint16_t pass = (int)[[NSDate date] timeIntervalSince1970]%3600;
                        
                        [self write:[NSData dataWithBytes:&pass length:sizeof(pass)] withUUID:[CBUUID UUIDWithString:UUID_ZERO] fromPeripheral:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
                    }
                    
                }];
                
                //读取电量
                [self read:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL] fromPeripheral:[CBUUID UUIDWithCFUUID:peripheral.UUID] withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
                    
                    //读取完名称和电量后
                    self.globals.bleListCount+=0;
                    self.globals.isConnectedBLE = YES;
                    
                    if ([bp.name isEqual:[[NSString alloc] initWithData:_setupName encoding:NSASCIIStringEncoding]]) {
                        
                        NSLog(@"finish");
                        
                        _setupblock(0);
                        
                        _setupblock = nil;
                        _setupBand = nil;
                        _setupName = nil;
                    }
                    
                }];
            }
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
        
//        [peripheral readValueForCharacteristic:characteristic];

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
    
    NSLog(@"c:%@, v:%@", characteristic.UUID, characteristic.value);
    
    //取出缓存中的block并执行
    void (^block)(NSData* value, CBCharacteristic* characteristic, CBPeripheral* peripheral)  = [bp.allCallback objectForKey:characteristic.UUID];
    
    if (block) { 
        block(characteristic.value, characteristic, peripheral);
    }
    
    [bp.allCallback removeObjectForKey:characteristic.UUID];
}

//写数据完成后的回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"WriteValueForCharacteristic error: %@", error.localizedDescription);
    }
    NSLog(@"write value: %@", characteristic.value);
    
    if (_setupBand != nil && [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_CUSTORM_NAME]]) {
        NSLog(@"we did it:%@", characteristic.value);
    }
}

//某个peripheral断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{

    //从缓存中移除
    [_allPeripherals removeObjectForKey:[CBUUID UUIDWithCFUUID:peripheral.UUID]];
    
    //设备总数减少
    self.globals.bleListCount--;
    
    if (self.globals.bleListCount == 0) {
        self.globals.isConnectedBLE = NO;
    }
    
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
        
        if (tmp && bp.handle.isConnected) {
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
        
        if (tmp && bp.handle.isConnected) {
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
    
//    [_cm scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID_METRONOME_SERVICE]] options:nil];
    [_cm scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID_HEALTH_SERVICE]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
    
    NSLog(@"scan ForPeripherals");
}

//和手环同步时间
-(void)sync:(CBUUID*)puuid{
    NSThread *syncTread = [[NSThread alloc] initWithTarget:self selector:@selector(doSync:) object:puuid];
    
    [syncTread start];
}

//60秒同步一次的函数句柄
-(void)sync60:(NSTimer*)timer{
    [self sync:timer.userInfo];
    
    //读取电量
    [self read:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL] fromPeripheral:timer.userInfo withBlock:^(NSData *value, CBCharacteristic *characteristic, CBPeripheral *peripheral) {
        
        //读取完名称和电量后
        self.globals.bleListCount+=0;
                                        
    }];
}

//同步操作的新线程
-(void)doSync:(CBUUID*)puuid{
    //调高优先级
    [NSThread setThreadPriority:1.0];
    
    //取得主线程
    uint8_t count = 0;
    Boolean isLock = NO;
    double sendTime = 0.0, now = 0.0;
    
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    //同步操作最开始的时刻
    double syncStart = mach_absolute_time() * 1.0e-9;
    syncStart *= info.numer;
    syncStart /= info.denom;
    
    while (count <SYNC_COUNT) {
        
        //在靠近触发时刻时加锁
        while (isLock) {
            now = mach_absolute_time() * 1.0e-9;
            now *= info.numer;
            now /= info.denom;
            
            if (now >= sendTime) {
                isLock = NO;
            }
        }
        
        //计算序号
        count++;
        isLock = YES;
        
        sendTime = syncStart +SYNC_INTERVAL * count;
        
        now = mach_absolute_time() * 1.0e-9;
        now *= info.numer;
        now /= info.denom;
        
        //缩短sleep时间，提前用死循环加锁
        [NSThread sleepForTimeInterval:sendTime - now - LOCK_TIME];
    }
    
    
}

//所有设备播放
-(void)playAllAt:(double)timestamp{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        if (bp.handle.isConnected) {
            
            
        }
        
    }
}

//所有设备暂停
-(void)pauseAll{
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    
    for (BTBandPeripheral* bp in enumeratorValue) {
        
    }
}

//返回蓝牙列表展示数据
-(NSArray*)bleList:(NSUInteger)index{
    
    //根据index找到对应的peripheral
    NSArray * ev = [[_allPeripherals objectEnumerator] allObjects];

    if (index >= ev.count) {
        NSLog(@"wo ca fdfd4");
        return NULL;
    }
    
    BTBandPeripheral* bp = [ev objectAtIndex:index];
    
    //0 是否连接
    NSNumber* isConnected = [NSNumber numberWithBool:bp.handle.isConnected];
    //1 设备名称
    NSString* bandName = bp.name;
    //2 电池电量
    uint8_t d;
    [[bp.allValues objectForKey:[CBUUID UUIDWithString:UUID_BATTERY_LEVEL]] getBytes:&d];
    NSNumber *batteryLevel = [NSNumber numberWithInt:d];
    
    NSLog(@"%@, %@, %@", isConnected, bandName, batteryLevel);
    
    return @[isConnected, bandName, batteryLevel];
}

//连接选中的peripheral
-(void)connectSelectedPeripheral:(NSUInteger)index{
    
    //根据index找到对应的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    BTBandPeripheral* bp = [[enumeratorValue allObjects] objectAtIndex:index];
    
    if (!bp.handle.isConnected) {
        [_cm connectPeripheral:bp.handle options:nil];
    } else {
        [_cm cancelPeripheralConnection:bp.handle];
    }
    
}

//定位将要进行初始化的peripheral
-(void)willSetup:(NSUInteger)index{
    //根据index找到对应的peripheral
    NSEnumerator * enumeratorValue = [_allPeripherals objectEnumerator];
    _setupBand = [[enumeratorValue allObjects] objectAtIndex:index];
}

//初始化手环
-(void)setup:(NSData*)data withBlock:(void(^)(int result))block{
    _setupName = data;
    _setupblock = block;
    
    [_cm connectPeripheral:_setupBand.handle options:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"bleShock"] || [keyPath isEqualToString:@"bleSpark"])
    {
        
        
    }
}

@end
