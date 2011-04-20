//
//  PostScoreController.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/19/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostScoreController : UIViewController {
    
    UITextField *userNameTextField;
}

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;

@property (assign) NSInteger numGuesses;
@property (nonatomic, retain) NSString *word;

- (IBAction)postButtonClicked:(id)sender;

@end
