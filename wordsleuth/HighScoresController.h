//
//  HighScoresController.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebugGestureView.h"

@interface HighScoresController : UIViewController <DebugViewDelegate> {
    
    IBOutlet UITableView *highScoresTableView;
    IBOutlet UILabel *yourScoreLabel;
    UILabel *timeLeftLabel;

    NSArray *scores;
    NSTimer *timer;
    UIButton *playAgainButton;
    
    BOOL bragsEnabled;
    UIAlertView *facebookBragPrompt;
    IBOutlet UILabel *bragLabel;
    UIButton *facebookBragButton;
    
    // DEBUG stuff
    BOOL debugTimer;
    NSDate *debugTimerExpiration;  
}

@property (nonatomic, retain) IBOutlet UITableView *highScoresTableView;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *yourScoreLabel;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) IBOutlet UIButton *playAgainButton;
@property (nonatomic, assign) int numGuesses;

@property (nonatomic, retain) DebugGestureView *debugGestureView;

@property (nonatomic, assign) BOOL bragsEnabled;
@property (nonatomic, retain) IBOutlet UILabel *bragLabel;
@property (nonatomic, retain) UIAlertView *facebookBragPrompt;
@property (nonatomic, retain) IBOutlet UIButton *facebookBragButton;

- (void)enableTimer;
- (NSMutableString *) formatTimeLeft:(int) secsuntilmidnight;
- (void)updateTimeLeft;
- (int)updateTimeLeftLabel;
- (IBAction)pressedPlayAgain:(id)sender;
- (void)togglePlayAgainButton:(BOOL)enabled;


- (IBAction)facebookBragPressed:(id)sender;



+ (UIColor*) highlightColor;

+ (void)goToHighScores:(int)numGuesses;

@end
