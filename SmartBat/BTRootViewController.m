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
    int screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    
    _commonViewCtrl = [BTCommonViewController buildView];
    _commonViewCtrl.view.tag = COMMON_VIEW;
    [self setViewX:-screenWidth who:_commonViewCtrl.view];
    [self.view addSubview:_commonViewCtrl.view];
    
    _noBandViewCtrl = [BTNoBandViewController buildView];
    _noBandViewCtrl.view.tag = NO_BAND_VIEW;
    [self setViewX:screenWidth who:_noBandViewCtrl.view];
    [self.view addSubview:_noBandViewCtrl.view];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _mainViewCtrl = [BTMainViewController buildView];
    _mainViewCtrl.view.tag = MAIN_VIEW;
    [_scrollView addSubview:_mainViewCtrl.view];
    
    _tempViewCtrl = [BTTempoViewController buildView];
    _tempViewCtrl.view.tag = TEMPO_VIEW;
    [self setViewX:screenWidth who:_tempViewCtrl.view];
    [_scrollView addSubview:_tempViewCtrl.view];
    
    _scrollView.contentSize = CGSizeMake(screenWidth * 2, screenWidth);
    
    _pageControl = (UIPageControl*)[self.view viewWithTag:PAGE_CONTROL_VIEW];
    [self.view bringSubviewToFront:_pageControl];
    
    NSLog(@"%@", _scrollView.subviews);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
