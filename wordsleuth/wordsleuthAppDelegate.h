//
//  wordsleuthAppDelegate.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PlayGameController.h"

extern NSString* const GameStateLoaded;

@interface wordsleuthAppDelegate : NSObject <UIApplicationDelegate> {

    PlayGameController *playGameController;
    UINavigationController *_navigationController;
    UIWindow *window;
    
    BOOL playedToday;
    BOOL launchDisplayCompleted;
    BOOL hasGameState;
    NSTimer *launchTimer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) PlayGameController *playGameController;

- (BOOL)checkPlayedToday;
- (int)getLastPlayedNumGuesses;

- (void) loadGameState;
- (void) loadGameView;
- (void)startGame;

@end
