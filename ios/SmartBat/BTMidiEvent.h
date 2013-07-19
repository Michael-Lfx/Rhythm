//
//  BMidiEvent.h
//  co.deluge.advancedmidi
//
//  Created by Ben Smiley-Andrews on 14/08/2012.
//  Copyright (c) 2012 Deluge. All rights reserved.
//

#import <Foundation/Foundation.h>

// Define the different availble event types
typedef enum {
	Note,
	Tempo,
	Lyric,
    Channel
} BTMidiEventType;

@interface BTMidiEvent : NSObject {
    NSInteger _startTime;
}

// In pulses
@property (nonatomic, readwrite) BTMidiEventType eventType;

-(void) setStartTime: (float) startTime;
-(NSInteger) getStartTime;

@end
