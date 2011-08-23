//
//  TimeUtilTest.m
//  wordsleuth
//
//  Created by Brian Elliott on 8/15/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "TimeUtilTest.h"
#import "TimeUtil.h"

@implementation TimeUtilTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testLastResetDate {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [cal setTimeZone:gmt];
    
    NSDateComponents *comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:2];
    [comps setHour:7];
    [comps setMinute:59];
    
    NSDate *date = [cal dateFromComponents:comps];
    [comps release];
    
    // pre 8am, should get day before
    NSDate *lastReset = [TimeUtil getLastResetDate:date];
    
    comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:1];
    [comps setHour:8];

    date = [cal dateFromComponents:comps];
    [comps release];
    
    STAssertEqualObjects(date, lastReset, @"Last Reset date %@ != %@", lastReset, date);
    

    // now test after 8 am
    comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:2];
    [comps setHour:8];
    [comps setMinute:1];
    
    date = [cal dateFromComponents:comps];
    [comps release];

    lastReset = [TimeUtil getLastResetDate:date];
    
    comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:2];
    [comps setHour:8];
    
    date = [cal dateFromComponents:comps];
    [comps release];

    STAssertEqualObjects(date, lastReset, @"Last Reset date %@ != %@", lastReset, date);

}

- (void)testNextResetDate {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [cal setTimeZone:gmt];

    NSDateComponents *comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:2];
    [comps setHour:7];
    [comps setMinute:59];

    NSDate *date = [cal dateFromComponents:comps];
    [comps release];

    // pre 8am, should get same day
    NSDate *nextReset = [TimeUtil getNextResetDate:date];
    
    comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:2];
    [comps setHour:8];
    
    date = [cal dateFromComponents:comps];
    [comps release];
    
    STAssertEqualObjects(date, nextReset, @"Next Reset date %@ != %@", nextReset, date);

    // now test after 8 am, should flip to next day.
    comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:2];
    [comps setHour:8];
    [comps setMinute:1];
    
    date = [cal dateFromComponents:comps];
    [comps release];
    
    nextReset = [TimeUtil getNextResetDate:date];
    
    comps = [NSDateComponents new];
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:3];
    [comps setHour:8];
    
    date = [cal dateFromComponents:comps];
    [comps release];
    
    STAssertEqualObjects(date, nextReset, @"Next Reset date %@ != %@", nextReset, date);
    

}

#endif

@end
