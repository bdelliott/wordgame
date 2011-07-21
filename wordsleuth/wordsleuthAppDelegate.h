//
//  wordsleuthAppDelegate.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BragFacebook.h"
#import "HighScoresController.h"
#import "PlayGameController.h"
#import "RatingDelegate.h"

extern NSString* const GameStateLoaded;
extern NSString* const ApplicationBecameActive;

@interface wordsleuthAppDelegate : NSObject <UIApplicationDelegate> {

    // brag stuff
    BragFacebook *bragFacebook;

    PlayGameController *playGameController;
    HighScoresController *highScoresController;
    
    UINavigationController *_navigationController;
    UIWindow *window;
    
    // app store ratings
    RatingDelegate *ratingDelegate;
    
}

@property (nonatomic, retain) BragFacebook *bragFacebook;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) PlayGameController *playGameController;
@property (nonatomic, retain) HighScoresController *highScoresController;

@property (nonatomic, retain) RatingDelegate *ratingDelegate;


- (void)loadApplication;
- (void)loadGameView;

- (void)configureAppRating;
- (void)promptForAppReviews;

- (void)resetGame;

- (BOOL)hasPlayedToday;
- (NSDate *) lastPlayedDate;
- (int)getLastPlayedNumGuesses;

- (void)goToScores:(int)lastPlayedNumGuesses;
- (void)startGame;

@end
