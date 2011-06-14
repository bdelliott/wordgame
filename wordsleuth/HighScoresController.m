//
//  SecondViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "HighScoresController.h"
#import "wordsleuthAppDelegate.h"

#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "WordURL.h"
#import "UIButton+Gradient.h"

@implementation HighScoresController

@synthesize highScoresTableView;
@synthesize timeLeftLabel;
@synthesize yourScoreLabel;
@synthesize timer;
@synthesize playAgainButton;
@synthesize numGuesses;

@synthesize debugGestureView;

@synthesize bragsEnabled;
@synthesize facebookBragPrompt;
@synthesize bragLabel;
@synthesize facebookBragButton;

+ (UIColor*) highlightColor {
    return [UIColor colorWithRed:.91f green:.67f blue:.15f alpha:1.0f];
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self)
        return nil;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Best Scores";
    
    self.numGuesses = 0;
    
    // bragging should only be enabled once we're in the app store.
    self.bragsEnabled = FALSE;
    
    self.facebookBragPrompt = [[UIAlertView alloc] initWithTitle:@"Brag on Facebook?" message:@"Would you like to brag about your score on Facebook?" delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"Brag!", nil];
    
    
    // DEBUG stuff:
    debugTimer = FALSE; // for debugging timer rollovers to the next day's word.  disable    
                       // for app store builds!!!
    debugTimerExpiration = nil;
    
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"HSC:viewWillAppear");

    [super viewWillAppear:animated];
    
    // hide bragging label and buttons until we retrieve the configuration setting
    // from the server
    self.bragLabel.hidden = YES;
    self.facebookBragButton.hidden = YES;

    // add an invisible view covering the whole frame for detecting 
    // debug gestures.  (iz the voodoo)
    CGRect wholeWindow = [self.view bounds];
    self.debugGestureView = [[DebugGestureView alloc] initWithFrame:wholeWindow];
    self.debugGestureView.delegate = self;
    [self.view addSubview:self.debugGestureView];
    [self.view sendSubviewToBack:self.debugGestureView];
    
    // if they solved it, show the user's score.
    if (self.numGuesses == 0) {
        self.yourScoreLabel.hidden = YES;
    } else {
        self.yourScoreLabel.hidden = NO;
        
        NSString *yourScore = [NSString stringWithFormat:@"Your Score: %d", self.numGuesses];
        self.yourScoreLabel.text = yourScore;
    }
    
    [self togglePlayAgainButton:NO];
    
    // if debug is enabled, setup the expiration time 15 seconds in the future
    if (debugTimer) {
        NSDate *now = [NSDate date];
        debugTimerExpiration = [now dateByAddingTimeInterval:15];
        [debugTimerExpiration retain];
    }

    [self updateTimeLeft];
    
    [self enableTimer];
    
    NSLog(@"Loading high scores");
    
    // load the high scores of the day
    NSURL *url = [WordURL getHighScoresURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (error) {
        // TODO failed to get word.  implement a disconnected mode from a limited set of words?
        NSLog(@"high scores load failed, error=%@", error);
        
    } else {
        NSString *response = [request responseString];
        NSDictionary *d = [response JSONValue];
        scores = (NSArray *)[d objectForKey:@"scores"];
        [scores retain];
        
        // check if bragging is enabled.
        NSNumber *brags = (NSNumber *)[d objectForKey:@"bragEnabled"];
        if (brags) {
            self.bragsEnabled = [brags boolValue];
        }
        
        NSLog(@"bragEnabled: %d", self.bragsEnabled);
    }  
    
    if (self.bragsEnabled) { 
        self.bragLabel.hidden = NO;
        self.facebookBragButton.hidden = NO;
    }

}

- (void)enableTimer {
    // turn on the countdown to next word timer.
    
    // schedule the timer:
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
    //NSLog(@"timer scheduled (%@)", self.timer);
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"HSC:viewWillDisappear");
    [super viewDidDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
        
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FullBackground.png"]];
    self.highScoresTableView.backgroundColor = [UIColor clearColor];    
    self.highScoresTableView.rowHeight = 34.0f;
    [self updateTimeLeftLabel];
    
    [self.playAgainButton styleWithGradientColor:[HighScoresController highlightColor]];

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
    [highScoresTableView release];
    highScoresTableView = nil;
    [self setTimeLeftLabel:nil];
    [self setPlayAgainButton:nil];
    [yourScoreLabel release];
    yourScoreLabel = nil;

    [self setFacebookBragButton:nil];
    
    [bragLabel release];
    bragLabel = nil;
    
    [super viewDidUnload];

    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [highScoresTableView release];
    highScoresTableView = nil;
    
    [timeLeftLabel release];
    timeLeftLabel = nil;
    
    [yourScoreLabel release];
    yourScoreLabel = nil;
    
    [playAgainButton release];
    playAgainButton = nil;
    
    [debugGestureView release];
    debugGestureView = nil;
    
    [yourScoreLabel release];
    yourScoreLabel =nil;
    
    [facebookBragPrompt release];
    facebookBragPrompt = nil;
    
    [facebookBragButton release];
    facebookBragButton = nil;
    
    [bragLabel release];
    bragLabel = nil;
    
    [debugTimerExpiration release];
    debugTimerExpiration = nil;

    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId = @"ScoreCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId] autorelease];        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:cell.detailTextLabel.font.pointSize];
    }
    
    NSDictionary *score = [scores objectAtIndex:indexPath.row];
    NSString *playerName = [score objectForKey:@"user_name"];
    NSDecimalNumber *playerGuesses = [score objectForKey:@"num_guesses"];
    cell.textLabel.text = playerName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", playerGuesses];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int numScores = [scores count];
    
    // limit to display of 7 scores, which is the magic number that fits
    // properly on an iphone screen.
    
    numScores = numScores > 7 ? 7 : numScores;
    return numScores;
}

+ (void)goToHighScores:(int)numGuesses {
    
    wordsleuthAppDelegate *delegate = (wordsleuthAppDelegate *)[[UIApplication sharedApplication] delegate];
    HighScoresController *highScoresController = [[HighScoresController alloc] initWithNibName:@"HighScores" bundle:nil];
    highScoresController.numGuesses = numGuesses;
    
    [delegate.navigationController pushViewController:highScoresController animated:TRUE];
    [highScoresController release];
}

- (NSDate *) getNextMidnight:(NSDate *) now  {
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    [offset setDay:1];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *tomorrow = [cal dateByAddingComponents:offset toDate:now options:0];
    
    [offset release];
    
    unsigned flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents *comps = [cal components:flags fromDate:tomorrow];
    NSInteger d = [comps day];
    NSInteger m = [comps month];
    NSInteger y = [comps year];

    // now build tomorrow with hour set to 12am when the word rolls over
    comps = [[NSDateComponents alloc] init];
    [comps setYear:y];
    [comps setMonth:m];
    [comps setDay:d];
    [comps setHour:0];
    
    NSDate *midnight = [cal dateFromComponents:comps];
    [comps release];
    
    return midnight;
}

- (NSMutableString *) formatTimeLeft: (int) secsuntilmidnight  {
    int hours = secsuntilmidnight / 3600;
    int remainder = secsuntilmidnight % 3600;
    int minutes = remainder / 60;
    int seconds = remainder % 60;
    
    NSMutableString *timeLeft = [NSMutableString string];
    
    if (hours > 0) { 
        [timeLeft appendFormat:@"%d:%02d:", hours, minutes];
    } else {
        [timeLeft appendFormat:@"%d:", minutes]; 
    }
    
    NSString *secondsFormat = nil;
    if (minutes > 0 || secsuntilmidnight > 60) { 
        secondsFormat = @"%02d";
    } else {
        secondsFormat = @"%d";
    }
    [timeLeft appendFormat:secondsFormat, seconds];
    
    return timeLeft;
}

- (void)updateTimeLeft {
    // timer callback.  update the label and then go to a new game if timer
    // is up
    
    //NSLog(@"HSC:updateTimeLeft");
    
    int secondsUntilMidnight = [self updateTimeLeftLabel];
    
    // BDE testing hack:
    //secondsUntilMidnight = 0;
    
    if (secondsUntilMidnight <= 0) {
        
        // disable time countdown.  show play button.
        
        [self.timer invalidate];
        self.timer = nil;
        
        [self togglePlayAgainButton:YES];
        
    }
    
}
- (int)updateTimeLeftLabel {
    // iphone date/time library is the poo.. the steaming kind
    
    NSDate *now = [NSDate date];    
    
    int secondsUntilMidnight = 0;
    if (debugTimer) {
        // should not be enabled for shipped version, debugging only.
        // pretend remaining time is very short so we can test game rollover.
        secondsUntilMidnight = (int)[debugTimerExpiration timeIntervalSinceDate:now];
        
    } else {
        NSDate *midnight = [self getNextMidnight: now];    
        secondsUntilMidnight = (int)[midnight timeIntervalSinceDate:now];
    }
    
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Play again in just %@!", [self formatTimeLeft: secondsUntilMidnight]];
    
    return secondsUntilMidnight;
}

- (IBAction)pressedPlayAgain:(id)sender {
    
    //NSLog(@"play again pressed");
    
    // restart the game
    
    wordsleuthAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate startGame];

}

- (IBAction)facebookBragPressed:(id)sender {
    
    // ask the user if they want to brag on facebook:
    [facebookBragPrompt show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        // brag about score on Facebook
        
        wordsleuthAppDelegate *appDelegate = (wordsleuthAppDelegate *)[[UIApplication sharedApplication] delegate];
         
        [appDelegate.bragFacebook brag:self.numGuesses];
    }
}


- (void)togglePlayAgainButton:(BOOL)enabled {
    
    if (enabled) {
        NSLog(@"enabling button");
        self.timeLeftLabel.hidden = YES;
        self.playAgainButton.hidden = NO;
    } else {
        NSLog(@"disabling button");
        self.timeLeftLabel.hidden = NO;
        self.playAgainButton.hidden = YES;
    }
}


-(void) debugGestureDetected {
    [self.timer invalidate];
    self.timer = nil;

    [self togglePlayAgainButton:YES];
}


@end
