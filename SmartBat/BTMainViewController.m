//
//  BTViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTMainViewController.h"

@interface BTMainViewController ()

@end

@implementation BTMainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self updateBPMDisplay];
    _intervalCount = 0;
    
    self.self.globals.waitForRestart = NO;
    
    self.metronomeCoreController = [BTMetronomeCoreController getController];
    self.tapController = [[BTTapController alloc]init];
    [self.tapController updateTargetCount:self.globals.beatPerMeasure];
    
    [self updateSubdivisionDisplay];
    
    //监控全局变量beatPerMinute的变化
    [self.globals addObserver:self forKeyPath:@"beatPerMinute" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"beatPerMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"noteType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"subdivision" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"currentNoteDuration" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"currentMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"systemStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.globals addObserver:self forKeyPath:@"beatInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)plusPressed:(UIButton *)sender {
    [self startChangeBPMTimer:BPM_PLUS interval:BPM_CHANGE_INTERVAL];
    [_changeBPMTimer fire];
}

- (IBAction)minusPressed:(UIButton *)sender {
    [self startChangeBPMTimer:BPM_MINUS interval:BPM_CHANGE_INTERVAL];
    [_changeBPMTimer fire];
}

- (IBAction)plusEnded:(UIButton *)sender {
    [self stopChangeBPMTImer];
    _intervalCount = 0;
}

- (IBAction)minusEnded:(UIButton *)sender {
    [self stopChangeBPMTImer];
    _intervalCount = 0;
}

- (IBAction)playPressed:(UIButton *)sender {
    
    if ([[self.globals.systemStatus valueForKey:@"playStatus"]boolValue] == NO) {
        [self.metronomeCoreController start] ;

    }else{
        [self.metronomeCoreController stop] ;
    }
    
}


- (IBAction)tapPressed:(UIButton *)sender {
    
    int tapCount = [self.tapController tap];
    
    if(tapCount > 0)
    {
        self.tapDisplay.text = [[NSString alloc]initWithFormat: @"%d of %d", tapCount, [self.tapController targetTapCount]];
    }
    else
    {
        self.tapDisplay.text = @"";
        
        if(![[self.globals.systemStatus valueForKey:@"playStatus"]boolValue])
        {
            
            [NSTimer scheduledTimerWithTimeInterval:self.globals.currentNoteDuration target:self selector:@selector(playPressed:) userInfo:nil repeats:NO];
            
        }
    }
    
}

//私有方法

//更新BPM显示
-(void)updateBPMDisplay{
    _mainNumber.text = [NSString stringWithFormat:@"%d", self.globals.beatPerMinute];
}

//更新节拍显示
-(void)updateBeatAndNoteDisplay
{
    NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/self.globals.noteType ];
    self.beatAndNoteDisplay.text =[ [NSString alloc]initWithFormat:@"%d/%d", self.globals.beatPerMeasure, n.intValue ];
}

-(void)updatePlayButtonBackgroundImage
{
    if([[self.globals.systemStatus valueForKey:@"playStatus"]boolValue])
    {
        NSString *filePath=[[NSBundle mainBundle] pathForResource:@"stop-button" ofType:@"png"];
        NSData *data=[NSData dataWithContentsOfFile:filePath];
        UIImage *image=[UIImage imageWithData:data];
        [self.playButton setBackgroundImage:image forState: NO];
    }
    else
    {
        NSString *filePath=[[NSBundle mainBundle] pathForResource:@"play-button" ofType:@"png"];
        NSData *data=[NSData dataWithContentsOfFile:filePath];
        UIImage *image=[UIImage imageWithData:data];
        [self.playButton setBackgroundImage:image forState: NO];
    }
    
}


//更新subdivision显示
-(void)updateSubdivisionDisplay
{
    NSNumber *n = [[NSNumber alloc]initWithFloat: 1 / (self.globals.noteType / self.globals.subdivision) ];
    NSString *filePath = nil;
    
    switch(n.intValue)
    {
        case 2:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_06" ofType:@"png"];
            break;
        case 4:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_07" ofType:@"png"];
            break;
        case 6:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_15" ofType:@"png"];
            break;
        case 8:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_12" ofType:@"png"];
            break;
        case 12:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_16" ofType:@"png"];
            break;
        case 16:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_22" ofType:@"png"];
            break;
        case 24:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_17" ofType:@"png"];
            break;
        case 32:
            filePath=[[NSBundle mainBundle] pathForResource:@"SubnoteSmall_23" ofType:@"png"];
            break;
    }
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    UIImage *image=[UIImage imageWithData:data];
    [self.subdivisionDisplay setImage:image];
    
    
}

//修改BPM
//用于定时器
-(void)changeBPM:(NSTimer*)timer{
    if([[timer userInfo] isEqual: BPM_PLUS]){
        self.globals.beatPerMinute++;
    }else{
        self.globals.beatPerMinute--;
    }
    
    //检查是否越界
    if (self.globals.beatPerMinute > BPM_MAX) {
        self.globals.beatPerMinute = BPM_MAX;
    }
    
    if (self.globals.beatPerMinute < BPM_MIN) {
        self.globals.beatPerMinute = BPM_MIN;
    }
    
    //执行n次，减小定时器间隔时间
    _intervalCount++;
    
    if(_intervalCount > BPM_CHANGE_FASTER_COUNT){
        //句柄要被消除，缓存userinfo
        NSString* op = [timer userInfo];
        
        //换成快速的间隔
        [self stopChangeBPMTImer];
        [self startChangeBPMTimer:op interval:BPM_CHANGE_INTERVAL_FASTER];
    }
}

//启动、停止定时器
-(void)startChangeBPMTimer:(NSString*)operation interval:(float)duration{
    if(_changeBPMTimer != nil) {
        [self stopChangeBPMTImer];
    }
    
    _changeBPMTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(changeBPM:) userInfo:operation repeats:YES];
}

-(void)stopChangeBPMTImer{
    [_changeBPMTimer invalidate];
    _changeBPMTimer = nil;
    
    NSLog(@"end");
}

//监控参数，更新显示
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beatPerMinute"])
    {
        [self updateBPMDisplay];
        
    }
    
    if([keyPath isEqualToString:@"beatPerMeasure"])
    {
        [self updateBeatAndNoteDisplay];
        [self.tapController updateTargetCount:self.globals.beatPerMeasure];
    }
    
    if([keyPath isEqualToString:@"noteType"])
    {
        [self updateBeatAndNoteDisplay];
    }
    
    if([keyPath isEqualToString:@"systemStatus"])
    {
        [self updatePlayButtonBackgroundImage];
    }
    
    if([keyPath isEqualToString:@"subdivision"])
    {
        [self updateSubdivisionDisplay];
    }
    
    if([keyPath isEqualToString:@"currentNoteDuration"] || [keyPath isEqualToString:@"currentMeasure"])
    {
        //发生改变，先让手环停止
        [self pauseBluetooth];
            
        //再开启定时器，稳定后再发请求
        _bleTimer = [NSTimer scheduledTimerWithTimeInterval:BLUETOOTH_DELAY target:self selector:@selector(bleWaitForRestart) userInfo:nil repeats:NO];
    }
    
    if([keyPath isEqualToString:@"systemStatus"])
    {
        if([[self.globals.systemStatus valueForKey:@"playStatus"] boolValue]){
            
            [self sendDurationAndMeasure];
            
            [self playBluetooth:[[self.globals.systemStatus valueForKey:@"playStatusChangedTime"] doubleValue]];
        }else{
            [self pauseBluetooth];
        }
    }
    
    if([keyPath isEqualToString:@"beatInfo"])
    {
        if (self.globals.waitForRestart && [[self.globals.beatInfo valueForKey:@"indexOfMeasure"] intValue] == 0) {
            
            self.globals.waitForRestart = NO;
            
            [self sendDurationAndMeasure];
            
            [self playBluetooth:[[self.globals.beatInfo valueForKey:@"hitTime"] doubleValue]];
        }
    }
}

//发送蓝牙播放停止指令
-(void)playBluetooth:(double)start{
    [self.bandCM playAllAt:start];
}

-(void)pauseBluetooth{
    //如有还未启动的定时器，直接干掉
    if(_bleTimer != nil) {
        [_bleTimer invalidate];
        _bleTimer = nil;
    }
    
    [self.bandCM pauseAll];
}

-(void)sendDurationAndMeasure{
    //传递拍子间隔
    uint32_t d = self.globals.currentNoteDuration * 1000000;
    
    NSLog(@"d is: %d", d);
    
    [self.bandCM writeAll:[NSData dataWithBytes:&d length:sizeof(d)] withUUID:[CBUUID UUIDWithString:METRONOME_DURATION_UUID]];
    
    NSLog(@"ARR: %@", self.globals.currentMeasure);
    
    //传递每小节几拍
    int len = self.globals.currentMeasure.count;
    uint8_t measure[len];
    
    for (int i = 0; i < len; i++) {
        measure[i] = [[self.globals.currentMeasure objectAtIndex:i] intValue];
    }
    
    [self.bandCM writeAll:[NSData dataWithBytes:measure length:sizeof(measure)] withUUID:[CBUUID UUIDWithString:METRONOME_MEASURE_UUID]];
}

-(void)bleWaitForRestart{
    
    self.globals.waitForRestart = YES;
}

@end
