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
    
    _globals = [BTGlobals sharedGlobals];
    [self setBPMDisplay];
    _intervalCount = 0;

    
    //test by poppy
    self.metronomeCoreController = [BTMetronomeCoreController getController];
    
    
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


-(void)setBPMDisplay{
    _mainNumber.text = [NSString stringWithFormat:@"%d", _globals.bitPerMinute];
}

-(void)changeBPM:(NSTimer*)timer{
    if([[timer userInfo] isEqual: BPM_PLUS]){
        _globals.bitPerMinute++;
    }else{
        _globals.bitPerMinute--;
    }
    
    [self setBPMDisplay];
    
    [self.metronomeCoreController setBpm:_globals.bitPerMinute];
    
    
    _intervalCount++;
    
    NSString* op = [timer userInfo];
    
    if(_intervalCount > BPM_CHANGE_FASTER_COUNT){
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

@end
