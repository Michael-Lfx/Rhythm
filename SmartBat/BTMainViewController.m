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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipeBegan{
    tempoView = [self.view.superview viewWithTag:TEMPO_VIEW];
}

-(void)swipe:(int)dis{
    NSLog(@"%d", dis);
    if(dis > 0){
        [self setViewX:(-_viewX + dis) who:tempoView];
    }else{
        [self setViewX:-_viewX who:tempoView];
    }
}

-(void)swipeEnded{
    int final = (int)tempoView.frame.origin.x, move2;
    
    if(final > (1 - THRESHOLD_2_COMPLETE) * -_viewX){
        move2 = 0;
    }else{
        move2 = -_viewX;
    }
    
    [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
        [self setViewX:move2 who:tempoView];
    } completion:^(BOOL finished) {
        
    }];
}

@end
