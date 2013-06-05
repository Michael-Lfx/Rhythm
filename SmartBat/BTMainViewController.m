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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipeBegan{
    _tempoView = [self.view.superview viewWithTag:TEMPO_VIEW];
}

-(void)swipe:(int)dis{
    NSLog(@"%d", dis);
    if(dis < 0){
        [self setViewX:(_viewX + dis) who:_tempoView];
    }else{
        [self setViewX:_viewX who:_tempoView];
    }
}

-(void)swipeEnded{
    int final = (int)_tempoView.frame.origin.x, move2;
    
    if(final < (1 - THRESHOLD_2_COMPLETE) * _viewX){
        move2 = 0;
    }else{
        move2 = _viewX;
    }
    
    [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
        [self setViewX:move2 who:_tempoView];
    } completion:^(BOOL finished) {
        
    }];
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
