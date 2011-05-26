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
}

@property (nonatomic, retain) IBOutlet UITableView *highScoresTableView;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *yourScoreLabel;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) IBOutlet UIButton *playAgainButton;
@property (nonatomic, assign) int numGuesses;

@property (nonatomic, retain) DebugGestureView *debugGestureView;

- (NSMutableString *) formatTimeLeft:(int) secsuntilmidnight;
- (void)updateTimeLeft;
- (int)updateTimeLeftLabel;
- (IBAction)pressedPlayAgain:(id)sender;

- (void)togglePlayAgainButton:(BOOL)enabled;

+ (UIColor*) highlightColor;

+ (void)goToHighScores:(int)numGuesses;

@end
