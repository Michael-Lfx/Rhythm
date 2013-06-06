//
//  BTConstants.h
//  SmartBat
//
//  Created by kaka' on 13-6-4.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SWIPE_2_MOVE_TIMES 1.2f
#define THRESHOLD_2_COMPLETE 0.3f
#define THRESHOLD_2_COMPLETE_DURETION 0.2f

#define MAIN_VIEW_TAG 11
#define TEMPO_VIEW_TAG  12
#define COMMON_VIEW_TAG  13
#define NO_BAND_VIEW_TAG  14
#define PAGE_CONTROL_TAG  1
#define COMMON_BUTTON_TAG  2
#define BAND_BUTTON_TAG  3

#define BPM_CHANGE_INTERVAL  0.2f
#define BPM_CHANGE_INTERVAL_FASTER  0.02f
#define BPM_CHANGE_FASTER_COUNT  5

#define BPM_MIN  30
#define BPM_MAX  220

#define BPM_PLUS  @"plus"
#define BPM_MINUS  @"minus"

@interface BTConstants : NSObject

@end
