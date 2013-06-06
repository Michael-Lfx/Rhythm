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
    
    [_globals addObserver:self forKeyPath:@"beatPerMinute" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
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

//修改BPM
//用于定时器
-(void)changeBPM:(NSTimer*)timer{
    if([[timer userInfo] isEqual: BPM_PLUS]){
        _globals.beatPerMinute++;
    }else{
        _globals.beatPerMinute--;
    }
    
    if (_globals.beatPerMinute > BPM_MAX) {
        _globals.beatPerMinute = BPM_MAX;
    }
    
    if (_globals.beatPerMinute < BPM_MIN) {
        _globals.beatPerMinute = BPM_MIN;
    }
    
//    [self updateBPMDisplay];
    [self.metronomeCoreController setBpm:_globals.beatPerMinute];
    
    //执行n次，减小定时器间隔时间
    _intervalCount++;
    
    if(_intervalCount > BPM_CHANGE_FASTER_COUNT){
        //句柄要被消除，缓存userinfo
        NSString* op = [timer userInfo];
        
        [self stopChangeBPMTImer];
        [self startChangeBPMTimer:op interval:BPM_CHANGE_INTERVAL_FASTER];
    }
}

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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beatPerMinute"])
    {
        [self updateBPMDisplay];
    }
}

@end
