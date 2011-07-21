//
//  ScorePoster.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/17/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"
#import "PlayGameController.h"
#import "PostScoreTextFieldDelegate.h"
#import "TSAlertView.h"
#import "wordsleuthAppDelegate.h"

@interface ScorePoster : NSObject <MBProgressHUDDelegate, TSAlertViewDelegate> {
    
    MBProgressHUD *hud;
    PlayGameController *playGameController;
    PostScoreTextFieldDelegate *alertViewDelegate;
    TSAlertView *alertView;
}

@property (nonatomic, retain) PlayGameController *playGameController;

- (void) post;

- (void)postScore:(NSString *)userName;
- (void)doPostScore:(NSString *)userName;


@end
