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
    return @"http://sparkleword.appspot.com/service";
}

+ (NSURL *)getURL:(NSString *)function {
    
    NSString *url = [NSString stringWithFormat:@"%@/%@", [self getBaseURL], function];
    return [NSURL URLWithString:url];
}

+ (NSURL *)getHighScoresURL {
    return [self getURL:@"get_scores"];
}


+ (NSURL *)getTimeURL {
    /* just a debug function at the moment. */
    return [self getURL:@"get_time"];
}

+ (NSURL *)getWordURL {
    
    return [self getURL:@"get_word"];
}

+ (NSURL *)postScoreURL:(NSString *)userName {
    NSString *s = [NSString stringWithFormat:@"post_score/%@", userName];
    NSString *escaped = [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [self getURL:escaped];
}


@end
