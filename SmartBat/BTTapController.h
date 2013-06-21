//
//  BTTapController.h
//  SmartBat
//
//  Created by poppy on 13-6-21.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TapBeatProtocal <NSObject>

-(void) processTapBPM: (int)BPM;

@end

@interface BTTapController : NSObject


-(void)initWithTapCount:(int)tapCount;
-(void)tap;

@end
