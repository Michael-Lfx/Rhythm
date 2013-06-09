//
//  BTSettingsViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSettingsViewController.h"

@interface BTSettingsViewController ()

@end

@implementation BTSettingsViewController

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
    
    //初始化关闭按钮
    UIButton *pickupBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pickupBtn setFrame:CGRectMake(200, 30, 100, 30)];
    [pickupBtn setTitle:@"pickup" forState:UIControlStateNormal];
    [pickupBtn addTarget:self action:@selector(pickupSettings:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:pickupBtn];
}

//回到不可见位置
-(IBAction)pickupSettings:(id)sender{
    [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
        //回到子类的原点
        [self setViewX:_originX];
    } completion:^(BOOL finished) {
        
    }];
}

//从不可见位置显示出来
-(void)callMeDisplay{
    [UIView animateWithDuration:THRESHOLD_2_COMPLETE_DURETION animations:^(void) {
        [self setViewX:0];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
