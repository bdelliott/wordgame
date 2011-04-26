//
//  FirstViewController.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSAlertView.h"

@interface PlayGameController : UIViewController <TSAlertViewDelegate> {
    
    BOOL solved;
    NSMutableArray *guesses;
    NSString *closestBeforeGuess;
    NSString *closestAfterGuess;
    
    UITextField *guessTextField;
    BOOL shouldDismissKeyboard;
    
    UILabel *beforeTextField;
    UILabel *afterTextField;
    UIButton *giveUp;
    UILabel *beforeLabel;
    UILabel *afterLabel;
}

@property (assign) BOOL solved;
@property (assign) NSInteger numGuesses;
@property (nonatomic, readonly) NSMutableArray *guesses;

@property (nonatomic, retain) NSString *word;

@property (nonatomic, retain) IBOutlet UITextField *guessTextField;
@property (nonatomic, retain) IBOutlet UILabel *numGuessesLabel;

@property (nonatomic, retain) IBOutlet UILabel *beforeLabel;
@property (nonatomic, retain) IBOutlet UILabel *afterLabel;

@property (nonatomic, retain) IBOutlet UILabel *beforeTextField;
@property (nonatomic, retain) IBOutlet UILabel *afterTextField;
@property (nonatomic, retain) IBOutlet UIButton *giveUp;
- (IBAction)guessMade:(id)sender;
- (IBAction)gaveUp:(id)sender;


- (void)checkGuess:(NSString *)guess;

- (void)guessBeforeWord:(NSString *)guess;
- (void)guessAfterWord:(NSString *)guess;
- (void)guessIsCorrect;

- (void)postScore:(NSString *)userName;
- (void)goToHighScores;
@end
