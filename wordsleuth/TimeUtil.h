//
//  TimeUtil.h
//  wordsleuth
//
//  Created by Brian Elliott on 8/15/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject

// Get date/time at which word last reset:
+ (NSDate *) getLastResetDate:(NSDate *)fromDate;

// Get date/time at which word next reset:
+ (NSDate *) getNextResetDate:(NSDate *)fromDate;

@end
