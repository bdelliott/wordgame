//
//  Analytics.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/15/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "Analytics.h"

#import "FlurryAPI.h"

void uncaughtExceptionHandler(NSException *exception) {
    // log uncaught exceptions into flurry
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

@implementation Analytics

+ (void)startAnalytics {
    
#ifdef DEBUG
    NSLog(@"Analytics:startAnalytics - skipping in debug build");
    return;
#endif
    
    [FlurryAPI startSession:@"2HD76PJHK695MXQ7ZEAS"]; // unique key for WdJ
    
    // use the device identifier to help us identify the user uniquely.  (yes user
    // could use multiple devices, but this will at least help us gauge how many
    // copies of our app are in use)
    UIDevice *device = [UIDevice currentDevice];
    NSString *udid = device.uniqueIdentifier;
    [FlurryAPI setUserID:udid];
    
    NSLog(@"Flurry API version: %@", [FlurryAPI getFlurryAgentVersion]);
    
    NSMutableDictionary *eventParams = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // add app version to event
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSLog(@"App version is: %@", version);
    
    [eventParams setObject:version forKey:@"version"];
    
    // add time to event
    NSDate *now = [NSDate date];
    [eventParams setObject:now forKey:@"date"];
    
    [FlurryAPI logEvent:@"App Launch" withParameters:eventParams];
}


+ (void)logEvent:(NSString *)eventName {
    
#ifdef DEBUG
    NSLog(@"Analytics:logEvent - skipping in debug build");
    return;
#endif
    
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
    [self logEvent:eventName withParameters:d];
}

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)params {
    
#ifdef DEBUG
    NSLog(@"Analytics:logEvent:withParameters - skipping in debug build");
    return;
#endif

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];

    NSDate *date = [NSDate date];
    [d setObject:date forKey:@"date"];

    [d addEntriesFromDictionary:params];
    
    [FlurryAPI logEvent:eventName withParameters:d];
}

@end
