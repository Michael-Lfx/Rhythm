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
    
    _mainViewCtrl = [BTMainViewController buildView];
    _mainViewCtrl.view.tag = MAIN_VIEW;
    [self.view addSubview:_mainViewCtrl.view];
    
    _tempViewCtrl = [BTTempoViewController buildView];
    _tempViewCtrl.view.tag = TEMPO_VIEW;
    [self setViewX:-screenWidth who:_tempViewCtrl.view];
    [self.view addSubview:_tempViewCtrl.view];
    
    _commonViewCtrl = [BTCommonViewController buildView];
    _commonViewCtrl.view.tag = COMMON_VIEW;
    [self setViewX:-screenWidth who:_commonViewCtrl.view];
    [self.view addSubview:_commonViewCtrl.view];
    
    _noBandViewCtrl = [BTNoBandViewController buildView];
    _noBandViewCtrl.view.tag = NO_BAND_VIEW;
    [self setViewX:screenWidth who:_noBandViewCtrl.view];
    [self.view addSubview:_noBandViewCtrl.view];
    
    UIPageControl* pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(100, 400, 40, 20)];
    pageControl.tag = PAGE_CONTROL_VIEW;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    
    NSLog(@"%@", self.view.subviews);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
