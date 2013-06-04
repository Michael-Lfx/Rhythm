//
//  BTTempoViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTTempoViewController.h"

@interface BTTempoViewController ()

@end

@implementation BTTempoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)swipe:(int)dis{
    NSLog(@"%d", dis);
    if(dis < 0){
        [self setViewX:dis];
    }else{
        [self setViewX:0];
    }
}

-(void)swipeEnded{
    int final = (int)self.view.frame.origin.x, move2;
    
    if(final < THRESHOLD_2_COMPLETE * -_viewX){
        move2 = -_viewX;
    }else{
        move2 = 0;
    }
    
    [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
        [self setViewX:move2];
    } completion:^(BOOL finished) {
        
    }];
}

@end
