//
//  WordURL.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/26/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "WordURL.h"


@implementation WordURL

+ (NSString *)getAppVersion {
    
    // set app version in the settings pane:
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
}
   
+ (NSString *)getBaseURL {
    return @"http://sparkleword.appspot.com";
}

+ (NSString *)getBaseServiceURL {
    return [NSString stringWithFormat:@"%@/service", [self getBaseURL]];
}

+ (NSString *)getServiceURLString:(NSString *)function {
    return [NSString stringWithFormat:@"%@/%@", [self getBaseServiceURL], function];    
}

+ (NSURL *)getServiceURL:(NSString *)function {
    
    NSString *url = [self getServiceURLString:function];
    return [NSURL URLWithString:url];
}

+ (NSURL *)getHighScoresURL:(int)year withMonth:(int)month andDay:(int)day { 
    NSString *baseURL = [self getServiceURLString:@"get_scores"];

    NSString *appVersion = [self getAppVersion];
    
    NSString *url = [NSString stringWithFormat:@"%@?v=%@&y=%d&m=%d&d=%d", baseURL, appVersion, year, month, day];
    //NSLog(@"url=%@", url);
    return [NSURL URLWithString:url];
}


+ (NSURL *)getTimeURL {
    /* just a debug function at the moment. */
    return [self getServiceURL:@"get_time"];
}

+ (NSURL *)getWordURL:(int)year withMonth:(int)month andDay:(int)day {
    
    NSString *baseURL = [self getServiceURLString:@"get_word"];
    
    NSString *appVersion = [self getAppVersion];
    
    NSString *url = [NSString stringWithFormat:@"%@?v=%@&y=%d&m=%d&d=%d", baseURL, appVersion, year, month, day];
    //NSLog(@"url=%@", url);
    return [NSURL URLWithString:url];
}

+ (NSURL *)postScoreURL:(NSString *)userName {
    NSString *s = [NSString stringWithFormat:@"post_score/%@", userName];
    NSString *escaped = [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self getServiceURL:escaped];
}

+ (NSString *)getWallPostIconURL {
    NSString *s = @"static/Icon-Small.png";
    return [NSString stringWithFormat:@"%@/%@", [self getBaseURL], s];
}

@end
