//
//  BTConstants.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float const SWIPE_2_MOVE_TIMES;
extern float const THRESHOLD_2_COMPLETE;
extern float const THRESHOLD_2_COMPLETE_DURETION;

extern int const MAIN_VIEW_TAG;
extern int const TEMPO_VIEW_TAG;
extern int const COMMON_VIEW_TAG;
extern int const NO_BAND_VIEW_TAG;
extern int const PAGE_CONTROL_TAG;
extern int const COMMON_BUTTON_TAG;
extern int const BAND_BUTTON_TAG;

extern float const BPM_CHANGE_INTERVAL;
extern float const BPM_CHANGE_INTERVAL_FASTER;
extern int const BPM_CHANGE_FASTER_COUNT;

extern int const BPM_MIN;
extern int const BPM_MAX;

extern NSString* const BPM_PLUS;
extern NSString* const BPM_MINUS;

@interface BTConstants : NSObject

@end
