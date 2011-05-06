//
//  FirstViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "PlayGameController.h"
#import <QuartzCore/QuartzCore.h>

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"

#import "HighScoresController.h"
#import "PostScoreTextFieldDelegate.h"
#import "WordURL.h"


@implementation PlayGameController

@synthesize solved;
@synthesize numGuesses;
@synthesize guesses;

@synthesize word;

@synthesize guessTextField;
@synthesize numGuessesLabel;
@synthesize beforeLabel;
@synthesize afterLabel;
@synthesize beforeTextField;
@synthesize afterTextField;
@synthesize giveUp;

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
    
    [self initGame];
    return self;
    
}

- (void)initGame {
    
    // load the word of the day
    NSURL *url = [WordURL getWordURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (error) {
        // TODO failed to get word.  implement a disconnected mode from a limited set of words?
        NSLog(@"word load failed, error=%@", error);
        
    } else {
        NSString *response = [request responseString];
        NSDictionary *d = [response JSONValue];
        
        word = [d objectForKey:@"word"];
        [word retain];
        
        
        NSLog(@"today's word is: %@", word);
        
    }
    
    numGuesses = 0;
    closestBeforeGuess = nil;
    closestAfterGuess = nil;
    
    guesses = [NSMutableArray arrayWithCapacity:32];
    [guesses retain];
    
    shouldDismissKeyboard = NO;
}

- (void) styleBackground {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlayGameBackground.png"]];
}

- (void) styleGiveUp {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.anchorPoint = CGPointMake(0.0f, 0.0f);
    gradient.position = CGPointMake(0.0f, 0.0f);
    gradient.bounds = giveUp.layer.bounds;
    gradient.cornerRadius = 10.0;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:0.92f
                                           green:0.0f
                                            blue:0.0f
                                           alpha:1.0].CGColor,
                       (id)[UIColor colorWithRed:0.62f
                                           green:0.0f
                                            blue:0.0f
                                           alpha:1.0].CGColor,
                       nil];
    gradient.zPosition = -100.0f;
    giveUp.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    giveUp.layer.shadowOpacity = 1.5f;
    giveUp.layer.shadowColor = [UIColor blackColor].CGColor;
    giveUp.layer.shadowRadius = 2.5f;
    /*
    gradient.borderColor = [UIColor colorWithRed:0.42f
                                               green:0.0f
                                                blue:0.0f
                                               alpha:1.0].CGColor;
    gradient.borderWidth = 1.0f;
     */
    [giveUp.layer addSublayer:gradient]; 
    
    giveUp.titleLabel.textColor = [UIColor whiteColor];
}

- (void) renderNumberOfGuesses {
    if (numGuesses > 0) {
        numGuessesLabel.text = [NSString stringWithFormat:@"%d", numGuesses];
    } else {
        numGuessesLabel.text = @"";
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self styleBackground];
    [self renderNumberOfGuesses];    
    [self styleGiveUp];
    
    [beforeLabel removeFromSuperview];
    [afterLabel removeFromSuperview];
    afterTextField.text = nil;
    beforeTextField.text = nil;
    
    [guessTextField becomeFirstResponder];
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

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [numGuessesLabel release];
    [guessTextField release];
    [beforeTextField release];
    [afterTextField release];
    [giveUp release];
    [beforeLabel release];
    [afterLabel release];
    
    [alertView release];
    [alertViewDelegate release];
    
    [super dealloc];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"textFieldShouldEndEditing");
    // stop keyboard from being dismissing when the Done button is touched
    return shouldDismissKeyboard;
}

- (IBAction)guessMade:(id)sender {
    NSLog(@"user made a guess");
    
    NSString *guess = guessTextField.text;
    guess = [guess lowercaseString];

    NSLog(@"user guessed '%@'", guess);
    
    [self checkGuess:guess];
    
    // clear guess
    guessTextField.text = nil;
}

- (IBAction)gaveUp:(id)sender {
    // user gave up, just tell them the answer
    
    self.solved = FALSE;
    
    [self saveLastPlayed];
    
    NSString *msg = [NSString stringWithFormat:@"The word of the day is '%@'.  Better luck next time!", word];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No luck, eh?" message:msg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    [alertView show];

}

- (void)checkGuess:(NSString *)guess {
    
    BOOL wrong = FALSE;
    
    [guesses addObject:guess];
    numGuesses++;
    [self renderNumberOfGuesses];
    

    // check user's guess:
    
    // compare to our magic word
    NSComparisonResult cmp = [word localizedCaseInsensitiveCompare:guess];
    switch (cmp) {
        case NSOrderedAscending:
            // word is before guess
            wrong = TRUE;
            [self guessAfterWord:guess];
            break;
            
        case NSOrderedSame:
            // user guessed right
            [self guessIsCorrect];
            break;
            
        case NSOrderedDescending:
            // word is after guess
            wrong = TRUE;
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
        closestBeforeGuess = guess;
    } else {
        
        NSComparisonResult cmp = [closestBeforeGuess localizedCaseInsensitiveCompare:guess];
        if (cmp == NSOrderedAscending) {
            NSLog(@"%@ is after previous closest 'before' guess %@", guess, closestBeforeGuess);
            closestBeforeGuess = guess;
        }
                                                                             
    }
    
    [self.view addSubview:beforeLabel];
    beforeTextField.text = closestBeforeGuess;
}

- (void)guessAfterWord:(NSString *)guess {
    // compare to previous closest "after" guess
    
    if (!closestAfterGuess) {
        closestAfterGuess = guess;
    } else {
        NSComparisonResult cmp = [closestAfterGuess localizedCaseInsensitiveCompare:guess];
        if (cmp == NSOrderedDescending) {
            NSLog(@"%@ is before previous closest 'after' guess %@", guess, closestAfterGuess);
            closestAfterGuess = guess;
        }
    }
    
    [self.view addSubview:afterLabel];
    afterTextField.text = closestAfterGuess;
}

- (void)guessIsCorrect {
    // do all the you-win stuff.
    NSLog(@"winner winner chicken dinner");
    
    self.solved = TRUE;
    [self saveLastPlayed];

    
    shouldDismissKeyboard = YES;
    [guessTextField resignFirstResponder];
    
    NSString *try;
    if (numGuesses == 1) 
        try = @"try";
    else
        try = @"tries";
        
    NSString *msg = [NSString stringWithFormat:@"You guessed '%@' correctly in %d %@. \n\nEnter a username for your score:", word, numGuesses, try];
    
    alertView.title = @"You got it!";
    alertView.message = msg;
    
    CGFloat f = 150;
    alertView.width = f;
    
    alertView.delegate = self;
    alertView.buttonLayout = TSAlertViewButtonLayoutNormal;
    alertView.usesMessageTextView = FALSE;
    
    alertView.style = TSAlertViewStyleInput;
    [alertView addButtonWithTitle:@"Post Score"];
    
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

- (void)alertView:(TSAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.alertView) {
        
        NSString *userName = alertView.inputTextField.text;
        [self postScore:userName];
    } else {
        // give up button
        [self postScore:nil];
    }
    
}

- (void)postScore:(NSString *)userName {
    
    NSLog(@"postScore: %@", userName);
    if (solved) {
        NSLog(@"postScore: solved, so posting");
        
        NSURL *url = [WordURL postScoreURL:userName];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        NSString *numGuessStr = [NSString stringWithFormat:@"%d", numGuesses];
        
        [request setPostValue:numGuessStr forKey:@"num_guesses"];
        [request setPostValue:word forKey:@"word"];
        
        [request startSynchronous];
        
        
        NSError *error = [request error];
        if (error || [request responseStatusCode] != 200) {
            // score post failed
            NSLog(@"score post failed");
            
        } else {
            
            // score posted, get high scores
            NSLog(@"score successfully posted");        
            
            // save the username for next time
            [self saveUserName:userName];
        }
    }
    
    NSLog(@"going to high scores view");
    [HighScoresController goToHighScores];

}

- (void)saveLastPlayed {
    // save last played date/time -- called after user wins or gives
    // up
    NSDate *newLastPlayed = [NSDate date];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:newLastPlayed forKey:@"lastPlayed"];
    
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
