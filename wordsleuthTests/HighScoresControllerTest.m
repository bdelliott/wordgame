//
//  HighScoresControllerTest.m
//  wordsleuth
//
//  Created by Matthew Botos on 5/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "HighScoresControllerTest.h"


@implementation HighScoresControllerTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) setUp {
    controller = [[HighScoresController alloc] init];
}

- (void)testGetNextMidnight {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateComponents *comps = [NSDateComponents new];
    
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:10];
    
    NSDate *d = [cal dateFromComponents:comps];
    
    [comps release];
    
    comps = [NSDateComponents new];
    
    [comps setYear:2011];
    [comps setMonth:8];
    [comps setDay:11];

    NSDate *d2 = [cal dateFromComponents:comps];

    NSDate *midnight = [controller getNextMidnight:d];
    
    STAssertEqualObjects(d2, midnight, @"Not equal to 8/11/2011 midnight GMT!", midnight);
    NSLog(@"midnight == %@", midnight);
}

- (void)testFormatHourWithZeroMinutes {
    
    STAssertEqualObjects([controller formatTimeLeft:3600], @"1:00:00", @"Incorrect format");
    
}
 
- (void)testFormatHourWithZeroHours {
    
    STAssertEqualObjects([controller formatTimeLeft:66], @"1:06", @"Incorrect format");
    
}

- (void)testFormatHourWithLessThan10Seconds {
    
    STAssertEqualObjects([controller formatTimeLeft:6], @":06", @"Incorrect format");
    
}

- (void) tearDown {
    [controller release];
}
                                

#endif

@end
