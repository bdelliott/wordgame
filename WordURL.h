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
+ (NSURL *)getURL:(NSString *)function;

+ (NSURL *)getHighScoresURL;
+ (NSURL *)getTimeURL;
+ (NSURL *)getWordURL;
+ (NSURL *)postScoreURL:(NSString *)userName;

@end
