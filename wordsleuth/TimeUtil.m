//
//  TimeUtil.m
//  wordsleuth
//
//  Created by Brian Elliott on 8/15/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil

// Get date/time at which word last reset:
+ (NSDate *) getLastResetDate:(NSDate *)fromDate {

    NSDate *date;
    
    if (fromDate) {
        date = [fromDate copy];
    }
    if (!fromDate) {
        date = [NSDate date]; // utc
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [cal setTimeZone:gmt];
    
    // word rolls over at GMT + 8 hours. (8:00 am)  This allows the word
    // to flip past midnight in all US time zones, with the word flipping
    // at exactly 12:00 am on the west coast. (US PST/daylight savings)
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | 
                         NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents *comps = [cal components:flags fromDate:date];
    
    NSInteger hour = [comps hour];
    
    NSDate *lastReset;
    
    if (hour < 8) {
        // word hasn't flipped over yet.  yesterday, 8 am is the current
        // word.
        
        NSTimeInterval secsPerDay = -(60*60*24); 
        date = [date dateByAddingTimeInterval:secsPerDay];
        comps = [cal components:flags fromDate:date];
        [comps setHour:8];
        lastReset = [cal dateFromComponents:comps];
        
    } else {
        // today, 8 am.
        [comps setHour:8];
        lastReset = [cal dateFromComponents:comps];
    }
    
    return lastReset;
}

// Get date/time at which word next reset:
+ (NSDate *) getNextResetDate:(NSDate *)fromDate {
    
    NSDate *date;
    
    if (fromDate) {
        date = [fromDate copy];
    }
    if (!fromDate) {
        date = [NSDate date]; // utc
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [cal setTimeZone:gmt];

    // word rolls over at GMT + 8 hours. (8:00 am)  This allows the word
    // to flip past midnight in all US time zones, with the word flipping
    // at exactly 12:00 am on the west coast. (US PST/daylight savings)
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | 
    NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents *comps = [cal components:flags fromDate:date];
    
    NSInteger hour = [comps hour];
    
    NSDate *nextReset;
    
    if (hour < 8) {
        
        // reset is today, just haven't reached it yet
        [comps setHour:8];
        nextReset = [cal dateFromComponents:comps];
    } else {
        // tomorrow, 8 am
        date = [date dateByAddingTimeInterval:(60*60*24)]; // add 24 hours
        comps = [cal components:flags fromDate:date];
        [comps setHour:8];
        
        nextReset = [cal dateFromComponents:comps];
    }
    
    return nextReset;
}

@end
