//
//  WordURL.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/26/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "WordURL.h"


@implementation WordURL

+ (NSString *)getBaseURL {
    return @"http://sparkleword.appspot.com";
}

+ (NSString *)getBaseServiceURL {
    return [NSString stringWithFormat:@"%@/service", [self getBaseURL]];
}

+ (NSURL *)getServiceURL:(NSString *)function {
    
    NSString *url = [NSString stringWithFormat:@"%@/%@", [self getBaseServiceURL], function];
    return [NSURL URLWithString:url];
}

+ (NSURL *)getHighScoresURL {
    return [self getServiceURL:@"get_scores"];
}


+ (NSURL *)getTimeURL {
    /* just a debug function at the moment. */
    return [self getServiceURL:@"get_time"];
}

+ (NSURL *)getWordURL {
    
    return [self getServiceURL:@"get_word"];
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
