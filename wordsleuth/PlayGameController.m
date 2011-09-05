//
//  FirstViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "PlayGameController.h"

#import "Analytics.h"
#import "HighScoresController.h"
#import "Notifications.h"
#import "ScorePoster.h"
#import "UIButton+Gradient.h"
#import "wordsleuthAppDelegate.h"
#import "WordURL.h"


@implementation PlayGameController

@synthesize gameState;

@synthesize guessTextField;
@synthesize numGuessesLabel;
@synthesize beforeLabel;
@synthesize afterLabel;
@synthesize beforeTextField;
@synthesize afterTextField;
@synthesize giveUp;

@synthesize fetchWordErrorAlertView;

- (id) initWithGameState:(GameState *)gState {
    
    self = [super initWithNibName:@"PlayGame" bundle:nil];
    if (!self)
        return nil;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Word Du Jour";
    
    NSLog(@"initializing play game controller");
    
    self.gameState = gState;
    
    scorePoster = [[ScorePoster alloc] init];
    scorePoster.playGameController = self;
    
    // we need to know when word fetches are complete so we can allow play to begin:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordFetchingDone) name:NOTIFICATION_WORD_FETCH_DONE object:nil];
    
    return self;
    
}
 
- (void)resetGame {
    // play is locked down until word is finished fetching and viewDidLoad sets up all the
    // UI stuff.
    
    NSLog(@"PGC:resetGame");
    
    shouldDismissKeyboard = NO;
    
    wordFetchDone = FALSE;

    // reset actual game state and trigger word fetch.
    [gameState resetGame];
    
    
}

- (void)wordFetchingDone {
    // called when background word fetching is done.  free up the UI to allow game play to
    // begin
    
    if (gameState.word) {
        // good to go
        NSLog(@"PGC:wordFetchingDone - got word.");
        
        wordFetchDone = TRUE;
    } else {
        // no word - network connectivity failed repeatedly.  display error, etc.
        NSLog(@"PGC:wordFetchingDone - no word, doing error dialog.!");
        
        self.fetchWordErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Can't fetch today's word" message:@"An error occurred retrieving today's word.  Please confirm you have a network connection and try again." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        [fetchWordErrorAlertView show];
        
        
    }
}

- (void)waitUntilWordFetched {
    // this method will run in a background thread
    // until any outstanding background word fetches
    // are finished.
    
    while (!wordFetchDone) {
        sleep(0.5); // sleep 500 ms.
    }

}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"PGC:viewWillAppear");
    [super viewWillAppear:animated];
    
    [self showHelpForKey:@"hasSeenPlayGameHelp" title:@"Welcome to Word du Jour!" message:@"Guess today's word in as few tries as possible for the best score."];
    
    // reset UI elements
    numGuessesLabel.text = nil;
    guessTextField.text = nil;
    beforeTextField.text = nil;
    afterTextField.text = nil;
    
    [beforeLabel removeFromSuperview];
    [afterLabel removeFromSuperview];

    
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"PGC:viewDidAppear");
    [super viewDidAppear:animated];
    
    // log start of a game:
    [Analytics logEvent:@"Starting a game"];
    
    // if word already fetched, no need to wait at all:
    if (wordFetchDone) {
        NSLog(@"PGC:viewWillAppear: word fetch was freakin' fast, skipping HUD altogether.");
        [self grabKeyboard];
    } else {
        
        // show an activity indicator until the word fetching is done:
        wordFetchActivityHUD = [[MBProgressHUD alloc] initWithView:self.view];
        wordFetchActivityHUD.delegate = self;
        wordFetchActivityHUD.labelText = @"Loading word...";
        wordFetchActivityHUD.yOffset = -50;
        
        [self.view addSubview:wordFetchActivityHUD];
        
        [wordFetchActivityHUD showWhileExecuting:@selector(waitUntilWordFetched) onTarget:self withObject:nil animated:YES];
    }
    
}

- (void)hudWasHidden {

    [wordFetchActivityHUD removeFromSuperview];
    [wordFetchActivityHUD release];
    wordFetchActivityHUD = nil;
    
    [self grabKeyboard];
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

- (void) endGame {
    // clean up
    
    // log end of a game:
    [Analytics logEvent:@"Ending a game"];
    
    // log a game's end for ratings prompt purposes:
    [[iRate sharedInstance] logEvent:YES]; // YES means "do not prompt immediately"
    
    NSLog(@"going to high scores view");
    
    wordsleuthAppDelegate *appDelegate = (wordsleuthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate goToScores:self.gameState.numGuesses];
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
    if (self.gameState.numGuesses > 0) {
        numGuessesLabel.text = [NSString stringWithFormat:@"%d", self.gameState.numGuesses];
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
}


- (IBAction)guessMade:(id)sender {    
    NSString *guess = [[guessTextField.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"user guessed '%@'", guess);
    [self checkGuess:guess];
    
    // clear guess
    guessTextField.text = nil;
}

- (IBAction)gaveUp:(id)sender {
    // user touched the 'give up' button, confirm their intention:
    
    giveUpConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Giving up?" message:@"Are you sure you want to give up?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Give up", nil];
    [giveUpConfirmAlertView show];

}

- (void)checkGuess:(NSString *)guess {
    
    WordComparison cmp = [self.gameState checkGuess:guess];
    
    [self renderNumberOfGuesses];

    // check user's guess:

    // update ui based on the 'quality' of the guess:
    switch (cmp) {
        case WordCompareAfter:
            // word is before guess
            [self updateAfterWord:guess];
            break;
            
        case WordCompareExact:
            // user guessed right
            [self guessIsCorrect];
            break;
            
        case WordCompareBefore:
            // word is after guess
            [self updateBeforeWord:guess];
             break;
            
        default:
            // no UI update, guess did not make progress
            break;
            
    }
    
    
}

- (void)updateBeforeWord:(NSString *)guess {
    // compare to previous closest "before" guess
    
    [self.view addSubview:beforeLabel];
    beforeTextField.text = guess;
    
    NSString *message = [NSString stringWithFormat:@"Today's word is after \"%@\"; try guessing something later in the alphabet.", guess];
    [self showHelpForKey:@"hasSeenBeforeWordHelp" title:@"Good guess!" message:message];
}

- (void)updateAfterWord:(NSString *)guess {
    // compare to previous closest "after" guess
    
    [self.view addSubview:afterLabel];
    afterTextField.text = guess;
    
    NSString *message = [NSString stringWithFormat:@"Today's word is before \"%@\"; try guessing something earlier in the alphabet.", guess];
    [self showHelpForKey:@"hasSeenAfterWordHelp" title:@"Good guess!" message:message];
}

- (void)guessIsCorrect {
    // do all the you-win stuff.
    NSLog(@"winner winner chicken dinner");
    
    
    int numGuesses = [gameState numGuesses];
    [gameState saveLastPlayed:numGuesses];
    
    // log it:    
    NSNumber *numGuessesObj = [NSNumber numberWithInt:numGuesses];
    
    NSDictionary *eventParams = [NSDictionary dictionaryWithObjectsAndKeys:numGuessesObj, @"numGuesses", nil];
    [Analytics logEvent:@"User solved it" withParameters:eventParams];
    
    
    [self releaseKeyboard];
    
    [scorePoster post]; // do score posting mojo.
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == fetchWordErrorAlertView) {
        // just retry fetching today's view
        [self.gameState fetchWord];
        [fetchWordErrorAlertView release];
        
    } else if (alertView == giveUpConfirmAlertView) {
        // give up confirmation popup
        
        [giveUpConfirmAlertView release];
        giveUpConfirmAlertView = nil;

        if (buttonIndex == 1) {
            
            NSString *msg = [NSString stringWithFormat:@"The word of the day is '%@'.  Better luck next time!", self.gameState.word];

            giveUpAlertView = [[UIAlertView alloc] initWithTitle:@"No luck, eh?" message:msg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [giveUpAlertView show];
        }
    } else if (alertView == giveUpAlertView) {
        
        // user confirmed they want to give up
        NSLog(@"give up confirmed");
        
        // log it:    
        NSNumber *numGuessesObj = [NSNumber numberWithInt:self.gameState.numGuesses];
        
        NSDictionary *eventParams = [NSDictionary dictionaryWithObjectsAndKeys:numGuessesObj, @"numGuesses", nil];
        [Analytics logEvent:@"User gave up" withParameters:eventParams];
        
        [self.gameState saveLastPlayed:0];
        
        [self releaseKeyboard];
        [self endGame];
        
        [giveUpAlertView release];
        giveUpAlertView = nil;
    }
}

// Keyboard handling methods:
- (void)grabKeyboard {
    
    // keep keyboard up until play is done:
    shouldDismissKeyboard = NO;
    
    if ([guessTextField isFirstResponder]) {
        NSLog(@"PGC:grabKeyboard: guessTextField is already first responder.");
    }
    
    if (![guessTextField canBecomeFirstResponder]) {
        NSLog(@"PGC:grabKeyboard: guessTextField cannot BECOME first responder.");
    }
    // grab the editing focus:
    if (![guessTextField becomeFirstResponder]) { 
        NSLog(@"PGC:grabKeyboard: guessTextField failed to BECOME first responder.");
    }
}


- (void)releaseKeyboard {
    shouldDismissKeyboard = YES;
    
    if (![guessTextField canResignFirstResponder]) {
        NSLog(@"PGC:releaseKeyboard: guessTextField cannot RESIGN first responder.");
    }
    // grab the editing focus:
    if (![guessTextField resignFirstResponder]) { 
        NSLog(@"PGC:releaseKeyboard: guessTextField failed to RESIGN first responder.");
    }
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //NSLog(@"textFieldShouldEndEditing");
    // stop keyboard from being dismissed when the Done button is touched
    return shouldDismissKeyboard;
}

// Misc stuff:

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

// Cleanup methods:

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [numGuessesLabel release];
    [guessTextField release];
    [beforeTextField release];
    [afterTextField release];
    [giveUp release];
    [beforeLabel release];
    [afterLabel release];
    
    [scorePoster release];
    [fetchWordErrorAlertView release];
    
    [giveUpAlertView release];
    [giveUpConfirmAlertView release];
    
    [super dealloc];
}




@end
