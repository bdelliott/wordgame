//
//  HighScoresController.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HighScoresController : UIViewController {
    
    IBOutlet UITableView *highScoresTableView;
    UILabel *timeLeftLabel;

    NSArray *scores;
    NSTimer *timer;
    UIButton *playAgainButton;
}

@property (nonatomic, retain) IBOutlet UITableView *highScoresTableView;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) IBOutlet UIButton *playAgainButton;


- (void)updateTimeLeft;
- (int)updateTimeLeftLabel;
- (IBAction)pressedPlayAgain:(id)sender;

+ (UIColor*) highlightColor;

+ (void)goToHighScores;

@end
