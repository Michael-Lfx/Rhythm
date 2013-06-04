//
//  BTConfigs.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTConfigs : NSObject{
    float _swipe2MoveTimes;
    float _threshold2Complete;
    float _threshold2CompleteDuration;
    id _commomViewCtl;
}

@property(readonly) float swipe2MoveTimes;
@property(readonly) float threshold2Complete;
@property(readonly) float threshold2CompleteDuration;
@property(retain) id commonViewCtl;

+(BTConfigs*)sharedConfigs;

@end
