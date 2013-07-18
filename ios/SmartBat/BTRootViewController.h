//
//  BTRootViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBaseViewController.h"
#import "BTMainViewController.h"
#import "BTTempoViewController.h"
#import "BTCommonViewController.h"
#import "BTConstants.h"
#import "BTNoBandViewController.h"
#import "BTGlobals.h"
#import "BTAppStore.h"

@interface BTRootViewController : BTBaseViewController <UIScrollViewDelegate>{
    BTTempoViewController* _tempViewCtrl;
    BTMainViewController* _mainViewCtrl;
    BTCommonViewController* _commonViewCtrl;
    BTNoBandViewController* _noBandViewCtrl;
    UIScrollView* _scrollView;
    UIPageControl* _pageControl;
    BTAppStore* _appStore;
}

- (IBAction)callSettings:(UIButton *)sender;

@end
