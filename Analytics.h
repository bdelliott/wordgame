//
//  Analytics.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/15/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

void uncaughtExceptionHandler(NSException *exception);

@interface Analytics : NSObject {
    
}

+ (void)startAnalytics;

+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)params;

@end
