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
