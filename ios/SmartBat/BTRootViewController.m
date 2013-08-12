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
    int scrollY, scrollHeight;
    
    //如果是ip5的话，scrollview上面少40像素，里面的子view保持460高度不变
    if(IS_IP5){
        scrollY = IP5_Y_FIXED;
        scrollHeight = screenHeight - IP5_Y_FIXED;
    }else{
        scrollY = 0;
        scrollHeight = screenHeight;
    }
    
    _pageControl = (UIPageControl*)[self.view viewWithTag:PAGE_CONTROL_TAG];
    
    //初始化滚屏view
    //init时设置一屏的尺寸，这尼玛是大坑啊
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollY, screenWidth, scrollHeight)];
    //一屏一屏的滚
    _scrollView.pagingEnabled = YES;
    //不要滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    //有回弹效果
    _scrollView.bounces = YES;
    _scrollView.delegate = self;
    //把丫放到分页符下面
    [self.view insertSubview:_scrollView belowSubview:_pageControl];
    
    _mainViewCtrl = [BTMainViewController buildView];
    _mainViewCtrl.view.tag = MAIN_VIEW_TAG;
    [_mainViewCtrl setViewHeight:IP4_HEIGHT];
    [_scrollView addSubview:_mainViewCtrl.view];
    
    _tempViewCtrl = [BTTempoViewController buildView];
    _tempViewCtrl.view.tag = TEMPO_VIEW_TAG;
    [_tempViewCtrl setViewX:screenWidth];
    [_tempViewCtrl setViewHeight:IP4_HEIGHT];
    [_scrollView addSubview:_tempViewCtrl.view];
    
    //这里设置n个屏的总长度
    _scrollView.contentSize = CGSizeMake(screenWidth * 2, scrollHeight);
    
    //初始化设置页view
    //放到最上面，出现时遮住分页符、设置按钮神马的
    _commonViewCtrl = [BTCommonViewController buildView];
    _commonViewCtrl.view.tag = COMMON_VIEW_TAG;
    [_commonViewCtrl setViewX:-screenWidth];
    [self.view addSubview:_commonViewCtrl.view];
    
    _bandViewCtrl = [BTBandViewController buildView];
    _bandViewCtrl.view.tag = BAND_VIEW_TAG;
    [_bandViewCtrl setViewX:screenWidth];
    [self.view addSubview:_bandViewCtrl.view];
    
    NSLog(@"%@", self.view.subviews);
    
    //查询最新版本
    _appStore = [[BTAppStore alloc] init];
    [_appStore checkVersion];
    
    //请求给评个分
    [_appStore askGraed];
    
}

//滚动结束时调用
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

//调用设置页面
- (IBAction)callSettings:(UIButton *)sender {
    if(sender.tag == COMMON_BUTTON_TAG){
        [_commonViewCtrl callMeDisplay];
    }else{
        [_bandViewCtrl callMeDisplay];
    }
}
@end
