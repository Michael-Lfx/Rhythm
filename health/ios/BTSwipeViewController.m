//
//  BTSwipeViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTSwipeViewController.h"

@interface BTSwipeViewController ()

@end

@implementation BTSwipeViewController

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
    
//    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [settingsBtn setFrame:CGRectMake(266, 20, 44, 34)];
//    [settingsBtn setBackgroundImage:[UIImage imageNamed:@"common.png"] forState:UIControlStateNormal];
//    [settingsBtn addTarget:self action:@selector(callCommonSettings:) forControlEvents:UIControlEventTouchDown];
//    [self.view addSubview:settingsBtn];
//    
//    UIButton *bandBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [bandBtn setFrame:CGRectMake(10, 20, 44, 34)];
//    [bandBtn setBackgroundImage:[UIImage imageNamed:@"band.png"] forState:UIControlStateNormal];
//    [bandBtn addTarget:self action:@selector(callBandSettings:) forControlEvents:UIControlEventTouchDown];
//    [self.view addSubview:bandBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
