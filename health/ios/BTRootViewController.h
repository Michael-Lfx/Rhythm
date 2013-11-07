//
//  BTRootViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBandCentral.h"
#import "BTBaseViewController.h"
#import "BTMainViewController.h"
#import "BTAskViewController.h"
#import "BTCommonViewController.h"
#import "BTConstants.h"
#import "BTBandViewController.h"
#import "BTGlobals.h"
#import "BTAppStore.h"
#import "BTNewsViewController.h"

@interface BTRootViewController : BTBaseViewController <UIScrollViewDelegate>{
    BTAskViewController* _askViewCtrl;
    BTNewsViewController* _newsViewCtrl;
    BTMainViewController* _mainViewCtrl;
    BTCommonViewController* _commonViewCtrl;
    BTBandViewController* _bandViewCtrl;
    UIScrollView* _scrollView;
    UIPageControl* _pageControl;
    BTAppStore* _appStore;
}

- (IBAction)callSettings:(UIButton *)sender;

@end
