//
//  BragFacebook.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/7/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBConnect.h"

@interface BragFacebook : NSObject <FBRequestDelegate, FBSessionDelegate> {
    
    Facebook *facebook;
    NSInteger numGuesses;
    
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) NSInteger numGuesses;

@property (nonatomic, retain) UIAlertView *bragConfirmationView;

- (void) brag:(NSInteger)score;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

- (void)saveFacebookSession;

@end
