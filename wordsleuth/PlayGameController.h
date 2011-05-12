//
//  FirstViewController.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostScoreTextFieldDelegate.h"
#import "TSAlertView.h"

@interface PlayGameController : UIViewController <TSAlertViewDelegate> {
    
    NSString *closestBeforeGuess;
    NSString *closestAfterGuess;
    
    UITextField *guessTextField;
    BOOL shouldDismissKeyboard;
    
    UILabel *beforeTextField;
    UILabel *afterTextField;
    UIButton *giveUp;
    UILabel *beforeLabel;
    UILabel *afterLabel;
    
    TSAlertView *alertView;
    PostScoreTextFieldDelegate *alertViewDelegate;
}

@property (assign) NSInteger numGuesses;
@property (nonatomic, retain) NSMutableArray *guesses;

@property (nonatomic, retain) NSString *word;

@property (nonatomic, retain) IBOutlet UITextField *guessTextField;
@property (nonatomic, retain) IBOutlet UILabel *numGuessesLabel;

@property (nonatomic, retain) IBOutlet UILabel *beforeLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterLabel;

@property (nonatomic, retain) IBOutlet UILabel *beforeTextField;
@property (nonatomic, retain) IBOutlet UILabel *afterTextField;
@property (nonatomic, retain) IBOutlet UIButton *giveUp;


@property (nonatomic, retain) TSAlertView *alertView;

- (void) initGame;
- (void) endGame;

- (IBAction)guessMade:(id)sender;
- (IBAction)gaveUp:(id)sender;


- (void)checkGuess:(NSString *)guess;

- (void)guessBeforeWord:(NSString *)guess;
- (void)guessAfterWord:(NSString *)guess;
- (void)guessIsCorrect;

- (NSString *)getSavedUserName;
- (void)saveUserName:(NSString *)userName;

- (void)postScore:(NSString *)userName;

- (void)saveLastPlayed;

@end
