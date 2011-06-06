//
//  RatingDelegate.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/6/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "RatingDelegate.h"


@implementation RatingDelegate

- (void)iRateCouldNotConnectToAppStore:(NSError *)error {
    NSLog(@"Failed to connect to app store: %@", error);
}
@end
