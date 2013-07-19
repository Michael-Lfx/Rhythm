//
//  BMidiEvent.m
//  co.deluge.advancedmidi
//
//  Created by Ben Smiley-Andrews on 14/08/2012.
//  Copyright (c) 2012 Deluge. All rights reserved.
//

#import "BTMidiEvent.h"

@implementation BTMidiEvent

@synthesize eventType;

- (NSComparisonResult)compare:(BTMidiEvent *)otherObject {
    NSNumber * this = [NSNumber numberWithDouble:_startTime];
    NSNumber * other = [NSNumber numberWithDouble:[otherObject getStartTime]];
    return [this compare:other];
}

-(void) setStartTime: (float) startTime {
    _startTime = (int) roundf(startTime);
}

-(NSInteger) getStartTime {
    return _startTime;
}

@end
