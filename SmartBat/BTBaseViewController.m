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
    
    [self clearXY];
    _globals = [BTGlobals sharedGlobals];
    
    _viewX = [UIScreen mainScreen].applicationFrame.size.width;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearXY{
    CGRect f = [self.view frame];
    f.origin.y = 0.0f;
    f.origin.x = 0.0f;
    self.view.frame = f;
}

-(void)setViewX:(int)x who:(UIView*)view{
    CGRect f = view.frame;
    f.origin.x = x;
    view.frame = f;
}

-(void)setViewX:(int)x{    
    CGRect f = self.view.frame;
    f.origin.x = x;
    self.view.frame = f;
}

@end
