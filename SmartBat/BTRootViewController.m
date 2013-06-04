//
//  BTRootViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTRootViewController.h"

@interface BTRootViewController ()

@end

@implementation BTRootViewController

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
    
    int screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    
    mainViewCtl = [BTMainViewController buildView];
    mainViewCtl.view.tag = MAIN_VIEW;
    [self.view addSubview:mainViewCtl.view];
    
    tempViewCtl = [BTTempoViewController buildView];
    tempViewCtl.view.tag = TEMPO_VIEW;
    [self setViewX:-screenWidth who:tempViewCtl.view];
    [self.view addSubview:tempViewCtl.view];
    
    commonViewCtl = [BTCommonViewController buildView];
    commonViewCtl.view.tag = COMMON_VIEW;
    [self setViewX:-screenWidth who:commonViewCtl.view];
    [self.view addSubview:commonViewCtl.view];
    
    NSLog(@"%@", self.view.subviews);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
