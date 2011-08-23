//
//  WordURL.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/26/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WordURL : NSObject {
    
}

+ (NSString *)getBaseURL;
+ (NSURL *)getServiceURL:(NSString *)function;

+ (NSURL *)getHighScoresURL:(int)year withMonth:(int)month andDay:(int)day;

+ (NSURL *)getTimeURL;

+ (NSURL *)getWordURL:(int)year withMonth:(int)month andDay:(int)day;

+ (NSURL *)postScoreURL:(NSString *)userName;

+ (NSString *)getWallPostIconURL;

@end
