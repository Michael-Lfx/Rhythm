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

    
    //test by poppy
    self.metronomeCoreController = [BTMetronomeCoreController getController];
    
    [self updateSubdivisionDisplay];
    
    //监控全局变量beatPerMinute的变化
    [_globals addObserver:self forKeyPath:@"beatPerMinute" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"beatPerMeasure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"noteType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_globals addObserver:self forKeyPath:@"subdivision" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
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
    
    [self.metronomeCoreController start] ;
    
}


- (IBAction)tapPressed:(UIButton *)sender {
    [self.metronomeCoreController stop] ;
}

//私有方法

//更新BPM显示
-(void)updateBPMDisplay{
    _mainNumber.text = [NSString stringWithFormat:@"%d", _globals.beatPerMinute];
}

//更新节拍显示
-(void)updateBeatAndNoteDisplay
{
    NSNumber *n = [[NSNumber alloc]initWithFloat:1.0/_globals.noteType ];
    self.beatAndNoteDisplay.text =[ [NSString alloc]initWithFormat:@"%d/%d", _globals.beatPerMeasure, n.intValue ];
}


//更新subdivision显示
-(void)updateSubdivisionDisplay
{
    NSNumber *n = [[NSNumber alloc]initWithFloat: 1 / (_globals.noteType / _globals.subdivision) ];
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
        _globals.beatPerMinute++;
    }else{
        _globals.beatPerMinute--;
    }
    
    //检查是否越界
    if (_globals.beatPerMinute > BPM_MAX) {
        _globals.beatPerMinute = BPM_MAX;
    }
    
    if (_globals.beatPerMinute < BPM_MIN) {
        _globals.beatPerMinute = BPM_MIN;
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
        _changeBPMTimer = nil;
    }
    
    _changeBPMTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(changeBPM:) userInfo:operation repeats:YES];
}

-(void)stopChangeBPMTImer{
    [_changeBPMTimer invalidate];
    _changeBPMTimer = nil;
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
    }
    
    if([keyPath isEqualToString:@"noteType"])
    {
        [self updateBeatAndNoteDisplay];
    }
    
    if([keyPath isEqualToString:@"subdivision"])
    {
        [self updateSubdivisionDisplay];
    }
}

@end
