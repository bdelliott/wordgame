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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self)
        return nil;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Word Du Jour";
    
    NSLog(@"initializing play game controller");
    
    gameState = [[GameState alloc] init];
    
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
    
    [wordLock release];
    
    shouldDismissKeyboard = NO;
    
    // locking/unlocking both occur from main thread!  (NSLocks and their variants require
    // same thread.)
    
    wordLock = [[NSCondition alloc] init];
    [wordLock lock];
    
    // reset actual game state and trigger word fetch.
    [gameState resetGame];
    
    
}

- (void)wordUnlock {
    [wordLock unlock];
}

- (void)wordFetchingDone {
    // called when background word fetching is done.  free up the UI to allow game play to
    // begin
    
    if (gameState.word) {
        // good to go
        NSLog(@"PGC:wordFetchingDone - got word.");
        
        // unlock play from main thread
        [self performSelectorOnMainThread:@selector(wordUnlock) withObject:nil waitUntilDone:NO];
        
    } else {
        // no word - network connectivity failed repeatedly.  display error, etc.
        NSLog(@"PGC:wordFetchingDone - no word, doing error dialog.!");
        
        self.fetchWordErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Can't fetch today's word" message:@"An error occurred retrieving today's word.  Please confirm you have a network connection and try again." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        [fetchWordErrorAlertView show];
        
        
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

    
    // log start of a game:
    [Analytics logEvent:@"Starting a game"];
    
    // keep keyboard up until play is done:
    shouldDismissKeyboard = NO;
    [guessTextField becomeFirstResponder]; // grab the editing focus
    
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
    [wordLock release];
    wordLock = nil;
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [wordLock release];
    [numGuessesLabel release];
    [guessTextField release];
    [beforeTextField release];
    [afterTextField release];
    [giveUp release];
    [beforeLabel release];
    [afterLabel release];
    
    [scorePoster release];
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
    NSNumber *numGuessesObj = [NSNumber numberWithInt:self.gameState.numGuesses];
    
    NSDictionary *eventParams = [NSDictionary dictionaryWithObjectsAndKeys:numGuessesObj, @"numGuesses", nil];
    [Analytics logEvent:@"User gave up" withParameters:eventParams];

    shouldDismissKeyboard = TRUE;
    
    [self.gameState saveLastPlayed:0];
    
    [guessTextField resignFirstResponder];
    
    NSString *msg = [NSString stringWithFormat:@"The word of the day is '%@'.  Better luck next time!", self.gameState.word];

    UIAlertView *gaveUpAlertView = [[[UIAlertView alloc] initWithTitle:@"No luck, eh?" message:msg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil] autorelease];
    [gaveUpAlertView show];

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
    
    
    shouldDismissKeyboard = YES;
    [guessTextField resignFirstResponder];
    
    [scorePoster post]; // do score posting mojo.
}

- (void)alertView:(TSAlertView *)aView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ((UIAlertView *)aView == fetchWordErrorAlertView) {
        // just retry fetching today's view
        [self.gameState fetchWord];
        [fetchWordErrorAlertView release];
        
    } else {
        // give up popup
        [self endGame];
    }
}

@end
