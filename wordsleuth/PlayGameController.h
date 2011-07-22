//
//  FirstViewController.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameState.h"
#import "MBProgressHUD.h"

@class ScorePoster;

@interface PlayGameController : UIViewController <MBProgressHUDDelegate> {
    
    GameState *gameState;
    
    UITextField *guessTextField;
    BOOL shouldDismissKeyboard;
    
    UILabel *beforeTextField;
    UILabel *afterTextField;
    UIButton *giveUp;
    UILabel *beforeLabel;
    UILabel *afterLabel;
    
    UIAlertView *fetchWordErrorAlertView;

    ScorePoster *scorePoster;
    
    BOOL wordFetchDone;
    MBProgressHUD *wordFetchActivityHUD;
}

@property (nonatomic, retain) GameState *gameState;

@property (nonatomic, retain) IBOutlet UITextField *guessTextField;
@property (nonatomic, retain) IBOutlet UILabel *numGuessesLabel;

@property (nonatomic, retain) IBOutlet UILabel *beforeLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterLabel;

@property (nonatomic, retain) IBOutlet UILabel *beforeTextField;
@property (nonatomic, retain) IBOutlet UILabel *afterTextField;
@property (nonatomic, retain) IBOutlet UIButton *giveUp;

@property (nonatomic, retain) UIAlertView *fetchWordErrorAlertView;

- (void) endGame;

- (IBAction)guessMade:(id)sender;
- (IBAction)gaveUp:(id)sender;

- (void)checkGuess:(NSString *)guess;

- (void)updateAfterWord:(NSString *)guess;
- (void)updateBeforeWord:(NSString *)guess;

- (void)guessIsCorrect;

- (void)resetGame;

- (void) showHelpForKey:(NSString*)hasSeenHelpKey title:(NSString*)title message:(NSString*)message;

@end
