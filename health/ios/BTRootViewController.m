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
    
    //测试电量时，屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [self configureViewOnRootView];
    
}
//configure view on rootView
- (void)configureViewOnRootView
{
    int screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    int screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    int scrollY, scrollHeight;
    
    float systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    NSLog(@"%d", screenHeight);
    
    //如果是ip5的话，scrollview上面少40像素，里面的子view保持460高度不变
    scrollY = 0;
    
    int buttonY = 0, pageY = 40;
    
    if (systemVer >= 7) {
        screenHeight += 20;
        scrollY += 20;
        buttonY = 20;
    }
    
    scrollHeight = screenHeight - scrollY;
    
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(142, screenHeight - pageY, 36, 36)];
    _pageControl.currentPage = 1;
    _pageControl.numberOfPages = 2;
    [self.view addSubview:_pageControl];
    
    UIButton *band = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    band.tag = BAND_BUTTON_TAG;
    [band setFrame:CGRectMake(0, buttonY, 54, 54)];
    [band setBackgroundImage:[UIImage imageNamed:@"common-button.png"] forState:UIControlStateNormal];
    [band addTarget:self action:@selector(callSettings:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:band];
    
    //    UIButton *common = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    common.tag = COMMON_BUTTON_TAG;
    //    [common setFrame:CGRectMake(266, buttonY, 54, 54)];
    //    [common setBackgroundImage:[UIImage imageNamed:@"common-button.png"] forState:UIControlStateNormal];
    //    [common addTarget:self action:@selector(callSettings:) forControlEvents:UIControlEventTouchDown];
    //    [self.view addSubview:common];
    
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
    
    //    _newsViewCtrl = [BTNewsViewController buildView];
    //    _newsViewCtrl.view.tag = NEWS_VIEW_TAG;
    //    [_newsViewCtrl setViewHeight:scrollHeight];
    //    [_scrollView addSubview:_newsViewCtrl.view];
    
    //main viewController
    _mainViewCtrl = [BTMainViewController buildView];
    _mainViewCtrl.view.tag = MAIN_VIEW_TAG;
    //    [_mainViewCtrl setViewX:screenWidth];
    [_mainViewCtrl setViewHeight:scrollHeight];
    [_scrollView addSubview:_mainViewCtrl.view];
    
    //胎动图片界面
    _askViewCtrl = [BTAskViewController buildView];
    _askViewCtrl.view.tag = TEMPO_VIEW_TAG;
    [_askViewCtrl setViewX:screenWidth];
    [_askViewCtrl setViewHeight:scrollHeight];
    [_scrollView addSubview:_askViewCtrl.view];
    
    //这里设置n个屏的总长度
  _scrollView.contentSize = CGSizeMake(screenWidth * 2, scrollHeight);
   [_scrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, scrollHeight) animated:YES];
//    
//    //初始化设置页view
    //放到最上面，出现时遮住分页符、设置按钮神马的
    _commonViewCtrl = [BTCommonViewController buildView];
    _commonViewCtrl.view.tag = COMMON_VIEW_TAG;
    [_commonViewCtrl setViewX:-screenWidth];
    [self.view addSubview:_commonViewCtrl.view];
   
    //setting viewController
   _bandViewCtrl = [BTBandViewController buildView];
    _bandViewCtrl.view.tag = BAND_VIEW_TAG;
   [_bandViewCtrl setViewX:screenWidth];
    [self.view  addSubview:_bandViewCtrl.view];
//    
//    NSLog(@"%@", self.view.subviews);
    
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
    NSLog(@"tag: %d", sender.tag);
    if(sender.tag == COMMON_BUTTON_TAG){
        [_commonViewCtrl callMeDisplay];
    }else{
        [_bandViewCtrl callMeDisplay];
    }
}
@end
