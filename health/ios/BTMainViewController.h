//
//  BTViewController.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTSwipeViewController.h"
#import "BTBandCentral.h"
#import "GraphView.h"
#import "CircularProgressView.h"

@interface BTMainViewController : BTSwipeViewController{
    
        GraphView *graphView;
}

@property(strong, nonatomic) NSMutableArray* dailyData;
@property(assign, nonatomic) int stepCount;

@property (strong, nonatomic) GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *sportNum;
@property (weak, nonatomic) IBOutlet UIImageView *sportLevel;
- (IBAction)sync:(id)sender;


@end
