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
}

@property (nonatomic, retain) IBOutlet UITableView *highScoresTableView;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;


- (void)updateTimeLeft;

+ (UIColor*) highlightColor;

+ (void)goToHighScores;

@end
