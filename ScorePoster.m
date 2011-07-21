//
//  ScorePoster.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/17/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "Analytics.h"
#import "ASIFormDataRequest.h"
#import "ScorePoster.h"
#import "WordURL.h"


@implementation ScorePoster

@synthesize playGameController;


- (id)init {
    self = [super init];
    if (self) {
        
        alertView = [[TSAlertView alloc] init];
        alertViewDelegate = [[PostScoreTextFieldDelegate alloc] init];
        
    }
    return self;
}

- (void)dealloc {
    [playGameController release];
    [alertView release];
    [alertViewDelegate release];
    
    [super dealloc];
    
}

- (void) post {
    
    GameState *gameState = playGameController.gameState;
    int numGuesses = [gameState numGuesses];
    
    NSString *try;
    if (numGuesses == 1) 
        try = @"try";
    else
        try = @"tries";
    
    NSString *msg;
    
        
    alertView.style = TSAlertViewStyleInput;
    msg = [NSString stringWithFormat:@"You guessed '%@' correctly in %d %@. \n\nEnter a username for your score:", [gameState word], numGuesses, try];
    
    alertView.title = @"You got it!";
    alertView.message = msg;
    
    CGFloat f = 150;
    alertView.width = f;
    
    alertView.delegate = self;
    alertView.buttonLayout = TSAlertViewButtonLayoutNormal;
    alertView.usesMessageTextView = FALSE;
    
    NSLog(@"numberOfButtons: %d", alertView.numberOfButtons);
    
    if (alertView.numberOfButtons == 0) {
        // only add the button for the first time they play.
        [alertView addButtonWithTitle:@"Skip"];
        [alertView addButtonWithTitle:@"Post Score"];
    }
    
    // use a separate delegate object so things don't get muddled with multiple
    // text fields in this controller
    alertView.inputTextField.delegate = alertViewDelegate;
    alertViewDelegate.alertView = alertView;
    
    // check for a saved user name to pre-populate the user name field:
    NSString *savedUserName = [gameState getSavedUserName];
    
    NSLog(@"savedUserName = %@", savedUserName);
    
    if (savedUserName) {
        alertView.inputTextField.text = savedUserName;
    }
    
    [alertView show];
}

- (void)alertView:(TSAlertView *)aView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // high score username popup.
    
    if (buttonIndex == 1) {
        // user chose to post their scores.
        
        NSString *userName;
        
        userName = alertView.inputTextField.text;
        
        [self postScore:userName]; // post to our score site
        
    } else {
        // user elected to skip posting their score.
        [playGameController endGame];
    }
}

- (void)postScore:(NSString *)userName {
    // disply an activity indictor to let user know we're chugging
    // along on stuff.
    
    
    NSLog(@"postScore: %@", userName);
    
    // log it:    
    [Analytics logEvent:@"Posting score"];
    
    // show progress indicator
    hud = [[MBProgressHUD alloc] initWithView:playGameController.navigationController.view];
	[playGameController.navigationController.view addSubview:hud];
	
    hud.delegate = self;
    hud.labelText = @"Posting Score";
	
    [hud showWhileExecuting:@selector(doPostScore:) onTarget:self withObject:userName animated:YES];
    
}

- (void)hudWasHidden {
    // clean up mb progress hud after it's no longer displayed
    
    NSLog(@"hudWasHidden");
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    [hud release];
	hud = nil;
    
    [playGameController endGame];
}



- (void)doPostScore:(NSString *)userName {
    // do the actual score posting
    
    GameState *gameState = playGameController.gameState;
    
    NSLog(@"doPostScore: userName=%@", userName);
    
    NSURL *url = [WordURL postScoreURL:userName];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *numGuessStr = [NSString stringWithFormat:@"%d", [gameState numGuesses]];
    
    [request setPostValue:numGuessStr forKey:@"num_guesses"];
    [request setPostValue:[gameState word] forKey:@"word"];
    
    [request startSynchronous];
    
    
    NSError *error = [request error];
    if (error || [request responseStatusCode] != 200) {
        // score post failed
        NSLog(@"score post url == %@", url);
        NSLog(@"Score post failed, error=%@, HTTP status code=%d",
              error, [request responseStatusCode]);
        
    } else {
        
        // score posted, get high scores
        NSLog(@"score successfully posted");        
        
        // save the username for next time
        [gameState saveUserName:userName];
    }
    
    sleep(1); // pause long enough that the indicator doesn't flash
    // by too fast.
}






@end
