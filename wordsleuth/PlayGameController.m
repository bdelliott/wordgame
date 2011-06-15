//
//  FirstViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "PlayGameController.h"

#import "Analytics.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"

#import "HighScoresController.h"
#import "PostScoreTextFieldDelegate.h"
#import "WordURL.h"
#import "UIButton+Gradient.h"
#import "iRate.h"


@implementation PlayGameController

@synthesize guesses;
@synthesize closestAfterGuess;
@synthesize closestBeforeGuess;

@synthesize word;

@synthesize guessTextField;
@synthesize numGuessesLabel;
@synthesize beforeLabel;
@synthesize afterLabel;
@synthesize beforeTextField;
@synthesize afterTextField;
@synthesize giveUp;

@synthesize fetchWordErrorAlertView;
@synthesize alertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self)
        return nil;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Word Du Jour";
    
    self.alertView = [[TSAlertView new] autorelease];
    alertViewDelegate = [[PostScoreTextFieldDelegate alloc] init];

    NSLog(@"initializing play game controller");
    
    return self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"PGC:viewWillAppear");
    [super viewWillAppear:animated];
    
    [self showHelpForKey:@"hasSeenPlayGameHelp" title:@"Welcome to Word du Jour!" message:@"Guess today's word in as few tries as possible for the best score."];
    
    [self initGame];
}

- (void) showHelpForKey:(NSString*)hasSeenHelpKey title:(NSString*)title message:(NSString*)message {
    BOOL hasSeenHelp = [[NSUserDefaults standardUserDefaults] boolForKey:hasSeenHelpKey];
    
    if (!hasSeenHelp) {
        UIAlertView *help = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [help show];
        [help release];
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:hasSeenHelpKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }    
}

- (void)initGame {
    
    NSLog(@"PGC:initGame");
    
    // log start of a game:
    [Analytics logEvent:@"Starting a game"];
    
    shouldDismissKeyboard = NO;
    [guessTextField becomeFirstResponder]; // grab the editing focus
    
    closestBeforeGuess = nil;
    closestAfterGuess = nil;
    
    self.guesses = [NSMutableArray array];

    [self fetchWord];
    
    // user may have played enough to get prompted for an app rating:
    if ([[iRate sharedInstance] shouldPromptForRating]) {
        // TODO BDE enable this once we have a working ratings url. bug #23
        //[[iRate sharedInstance] promptIfNetworkAvailable];
    } 
}

- (NSString *) fetchWord {
    // load the word of the day
    
    NSLog(@"fetchWord");
    
    NSURL *url = [WordURL getWordURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (error) {
        // TODO failed to get word.  implement a disconnected mode from a limited set of words?
        NSLog(@"word load failed, error=%@", error);

        // retry until successful, display network error to use on
        // failure
        
        self.fetchWordErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Can't fetch today's word" message:@"An error occurred retrieving today's word.  Please confirm you have a network connection and try again." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];

        [fetchWordErrorAlertView show];
        
        return nil;
        
    } else {
        NSString *response = [request responseString];
        NSLog(@"response==%@", response);
        NSDictionary *dictionary = [response JSONValue];
        
        self.word = [dictionary objectForKey:@"word"];
        
        NSLog(@"today's word is: %@", word);
        
        return word;
    }

}


- (void) endGame {
    // clean up
    
    // log end of a game:
    [Analytics logEvent:@"Ending a game"];

    int numGuesses = [self.guesses count];
    
    [word release];
    word = nil;

    [self.guesses removeAllObjects];
    self.closestBeforeGuess = nil;
    self.closestAfterGuess = nil;
    
    // log a game's end for ratings prompt purposes:
    [[iRate sharedInstance] logEvent:YES]; // YES means "do not prompt immediately"
    
    NSLog(@"going to high scores view");
    [HighScoresController goToHighScores:numGuesses];

}

- (void) styleBackground {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlayGameBackground.png"]];
}

- (void) styleGiveUp {
    [giveUp styleWithGradientColor:[UIColor colorWithRed:0.77f
                                                   green:0.0f
                                                    blue:0.0f
                                                   alpha:1.0]];
    giveUp.titleLabel.textColor = [UIColor whiteColor];
}

- (void) renderNumberOfGuesses {
    if ([self.guesses count] > 0) {
        numGuessesLabel.text = [NSString stringWithFormat:@"%d", [self.guesses count]];
    } else {
        numGuessesLabel.text = @"";
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"PGC:viewDidLoad");
    [super viewDidLoad];
    
    [self styleBackground];
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Title.png"]] autorelease];

    [self renderNumberOfGuesses];    
    [self styleGiveUp];
    
    [beforeLabel removeFromSuperview];
    [afterLabel removeFromSuperview];
    afterTextField.text = nil;
    beforeTextField.text = nil;
    
    BOOL accepts = [guessTextField becomeFirstResponder];
    NSLog(@"guessTextField accepts first responder status=%d", accepts);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setNumGuessesLabel:nil];
    [self setGuessTextField:nil];

    [self setBeforeTextField:nil];
    [self setAfterTextField:nil];
    [self setGiveUp:nil];
    [self setBeforeLabel:nil];
    [self setAfterLabel:nil];
    [super viewDidUnload];

}


- (void)dealloc
{
    [guesses release];
    [closestBeforeGuess release];
    [closestAfterGuess release];
    
    [numGuessesLabel release];
    [guessTextField release];
    [beforeTextField release];
    [afterTextField release];
    [giveUp release];
    [beforeLabel release];
    [afterLabel release];
    
    [alertView release];
    [alertViewDelegate release];
    [fetchWordErrorAlertView release];
    
    [super dealloc];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //NSLog(@"textFieldShouldEndEditing");
    // stop keyboard from being dismissed when the Done button is touched
    return shouldDismissKeyboard;
}

- (IBAction)guessMade:(id)sender {    
    NSString *guess = [[guessTextField.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"user guessed '%@'", guess);
    [self checkGuess:guess];
    
    // clear guess
    guessTextField.text = nil;
}

- (IBAction)gaveUp:(id)sender {
    // user gave up, just tell them the answer
    
    // log it:    
    NSNumber *numGuessesObj = [NSNumber numberWithInt:[self.guesses count]];
    
    NSDictionary *eventParams = [NSDictionary dictionaryWithObjectsAndKeys:numGuessesObj, @"numGuesses", nil];
    [Analytics logEvent:@"User gave up" withParameters:eventParams];

    shouldDismissKeyboard = TRUE;
    
    [self saveLastPlayed:0];
    
    [guessTextField resignFirstResponder];
    
    NSString *msg = [NSString stringWithFormat:@"The word of the day is '%@'.  Better luck next time!", word];

    UIAlertView *gaveUpAlertView = [[[UIAlertView alloc] initWithTitle:@"No luck, eh?" message:msg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil] autorelease];
    [gaveUpAlertView show];

}

- (void)checkGuess:(NSString *)guess {
    
    [guesses addObject:guess];
    [self renderNumberOfGuesses];
    

    // check user's guess:
    
    // compare to our magic word
    NSComparisonResult cmp = [word localizedCaseInsensitiveCompare:guess];
    switch (cmp) {
        case NSOrderedAscending:
            // word is before guess
            [self guessAfterWord:guess];
            break;
            
        case NSOrderedSame:
            // user guessed right
            [self guessIsCorrect];
            break;
            
        case NSOrderedDescending:
            // word is after guess
            [self guessBeforeWord:guess];
             break;
            
        default:
            NSLog(@"bad shit man.");
            exit(1);
            
    }
    
    
}

- (void)guessBeforeWord:(NSString *)guess {
    // compare to previous closest "before" guess
    
    if (!closestBeforeGuess) {
        self.closestBeforeGuess = guess;
    } else {
        
        NSComparisonResult cmp = [closestBeforeGuess localizedCaseInsensitiveCompare:guess];
        if (cmp == NSOrderedAscending) {
            NSLog(@"%@ is after previous closest 'before' guess %@", guess, closestBeforeGuess);
            self.closestBeforeGuess = guess;
        }
                                                                             
    }
    
    [self.view addSubview:beforeLabel];
    beforeTextField.text = closestBeforeGuess;
    
    NSString *message = [NSString stringWithFormat:@"Today's word is after \"%@\"; try guessing something later in the alphabet.", closestBeforeGuess];
    [self showHelpForKey:@"hasSeenBeforeWordHelp" title:@"Good guess!" message:message];
}

- (void)guessAfterWord:(NSString *)guess {
    // compare to previous closest "after" guess
    
    if (!closestAfterGuess) {
        self.closestAfterGuess = guess;
    } else {
        NSComparisonResult cmp = [closestAfterGuess localizedCaseInsensitiveCompare:guess];
        if (cmp == NSOrderedDescending) {
            NSLog(@"%@ is before previous closest 'after' guess %@", guess, closestAfterGuess);
            self.closestAfterGuess = guess;
        }
    }
    
    [self.view addSubview:afterLabel];
    afterTextField.text = closestAfterGuess;
    
    NSString *message = [NSString stringWithFormat:@"Today's word is before \"%@\"; try guessing something earlier in the alphabet.", closestBeforeGuess];
    [self showHelpForKey:@"hasSeenAfterWordHelp" title:@"Good guess!" message:message];
}

- (void)guessIsCorrect {
    // do all the you-win stuff.
    NSLog(@"winner winner chicken dinner");
    
    
    int numGuesses = [self.guesses count];
    [self saveLastPlayed:numGuesses];

    // log it:    
    NSNumber *numGuessesObj = [NSNumber numberWithInt:numGuesses];
    
    NSDictionary *eventParams = [NSDictionary dictionaryWithObjectsAndKeys:numGuessesObj, @"numGuesses", nil];
    [Analytics logEvent:@"User solved it" withParameters:eventParams];

    
    shouldDismissKeyboard = YES;
    [guessTextField resignFirstResponder];
    
    NSString *try;
    if (numGuesses == 1) 
        try = @"try";
    else
        try = @"tries";
        
    NSString *msg = [NSString stringWithFormat:@"You guessed '%@' correctly in %d %@. \n\nEnter a username for your score:", word, [self.guesses count], try];
    
    alertView.title = @"You got it!";
    alertView.message = msg;
    
    CGFloat f = 150;
    alertView.width = f;
    
    alertView.delegate = self;
    alertView.buttonLayout = TSAlertViewButtonLayoutNormal;
    alertView.usesMessageTextView = FALSE;
    
    alertView.style = TSAlertViewStyleInput;
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
    NSString *savedUserName = [self getSavedUserName];
    
    NSLog(@"savedUserName = %@", savedUserName);
    
    if (savedUserName) {
        alertView.inputTextField.text = savedUserName;
    }
    
    [alertView show];
}

- (void)alertView:(TSAlertView *)aView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ((UIAlertView *)aView == fetchWordErrorAlertView) {
        // just retry fetching today's view
        [self fetchWord];
        [fetchWordErrorAlertView release];
        
    } else if (aView == self.alertView) {
        // high score username popup.
        
        if (buttonIndex == 1) {
            NSString *userName = alertView.inputTextField.text;
            [self postScore:userName];
        } else {
            [self endGame];
        }
    } else {
        // give up popup
        [self endGame];
    }
}

- (void)postScore:(NSString *)userName {
    // disply an activity indictor to let user know we're chugging
    // along on stuff.
    
    
    NSLog(@"postScore: %@", userName);
    
    // log it:    
    [Analytics logEvent:@"Posting score"];
    
    // show progress indicator
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	
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
    
    [self endGame];
}



- (void)doPostScore:(NSString *)userName {
    // do the actual score posting
    
    NSLog(@"doPostScore: userName=%@", userName);
    
    NSURL *url = [WordURL postScoreURL:userName];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *numGuessStr = [NSString stringWithFormat:@"%d", [self.guesses count]];
    
    [request setPostValue:numGuessStr forKey:@"num_guesses"];
    [request setPostValue:word forKey:@"word"];
    
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
        [self saveUserName:userName];
    }
    
    sleep(1); // pause long enough that the indicator doesn't flash
              // by too fast.
}


- (void)saveLastPlayed:(int)numGuesses {
    // save last played date/time -- called after user wins or gives
    // up
    NSDate *newLastPlayed = [NSDate date];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:newLastPlayed forKey:@"lastPlayed"];
    
    // save number of guesses also
    // 0 guesses indicates that they gave up
    [standardUserDefaults setInteger:numGuesses forKey:@"lastPlayedNumGuesses"];
}

- (NSString *)getSavedUserName {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"savedUserName"];
}

- (void)saveUserName:(NSString *)userName {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:userName forKey:@"savedUserName"];
    [standardUserDefaults synchronize];
}





@end
