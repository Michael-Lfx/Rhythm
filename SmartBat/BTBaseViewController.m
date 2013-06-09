//
//  BTBaseViewController.m
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTBaseViewController.h"

@interface BTBaseViewController ()

@end

@implementation BTBaseViewController

-(id)init{
    self = [super init];
    if (self) {
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        //根据自己的类名在stroyboard里找视图实例
        self = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

+(id)buildView{
    return [[self alloc]init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //加载时把view重置到原点0,0
    CGRect f = [self.view frame];
    f.origin.y = 0.0f;
    f.origin.x = 0.0f;
    self.view.frame = f;
    
    //初始化全局变量为私有对象，供子类使用
    _globals = [BTGlobals sharedGlobals];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置水平位置
-(void)setViewX:(int)x{    
    CGRect f = self.view.frame;
    f.origin.x = x;
    self.view.frame = f;
}

//设置高度
-(void)setViewHeight:(int)h{
    CGRect f = self.view.frame;
    f.size.height = h;
    self.view.frame = f;
}

@end
