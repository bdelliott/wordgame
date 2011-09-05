//
//  HighScoresController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "HighScoresController.h"
#import "wordsleuthAppDelegate.h"

#import "ASIHTTPRequest.h"
#import "Analytics.h"
#import "NSString+SBJSON.h"
#import "TimeUtil.h"
#import "UIButton+Gradient.h"
#import "WordURL.h"

@implementation HighScoresController

@synthesize gameState;

@synthesize highScoresTableView;
@synthesize timeLeftLabel;
@synthesize yourScoreLabel;
@synthesize timer;
@synthesize playAgainButton;
@synthesize lastPlayedNumGuesses;

@synthesize debugGestureView;

@synthesize bragsEnabled;
@synthesize facebookBragPrompt;
@synthesize bragLabel;
@synthesize facebookBragButton;

+ (UIColor*) highlightColor {
    return [UIColor colorWithRed:.91f green:.67f blue:.15f alpha:1.0f];
}

- (id)initWithGameState:(GameState *)gState {

    self = [super initWithNibName:@"HighScores" bundle:nil];
    if (!self)
        return nil;
    
    self.gameState = gState;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Best Scores";
    
    self.lastPlayedNumGuesses = 0;
    
    // bragging should only be enabled once we're in the app store.
    self.bragsEnabled = FALSE;
    
    self.facebookBragPrompt = [[UIAlertView alloc] initWithTitle:@"Brag on Facebook?" message:@"Would you like to brag about your score on Facebook?" delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"Brag!", nil];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    lastFacebookBragDate = (NSDate *)[standardDefaults objectForKey:@"lastFacebookBragDate"];
    
#if TARGET_IPHONE_SIMULATOR 
    debugTimer = YES; // for debugging timer rollovers to the next day's word.  
#endif
    
    debugTimerExpiration = nil;
    
    
    // BDE commented this because this will fire any time the application
    // becomes active, which might result in 2 fetches for scores overlapping.
    // the results of 2 overlapping searches are unknown and may be harmful.
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selecto(loadBestScores) name:ApplicationBecameActive object:nil];
    
    return self;
}


- (void) loadBestScores {
    //NSLog(@"timer scheduled (%@)", self.timer);
    
    NSLog(@"Loading high scores");

    NSDate *lastResetDate = [TimeUtil getLastResetDate:nil];
    
    // interpret last reset as gmt
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [cal setTimeZone:gmt];
    
    // word rolls over at GMT + 8 hours. (8:00 am)  This allows the word
    // to flip past midnight in all US time zones, with the word flipping
    // at exactly 12:00 am on the west coast. (US PST/daylight savings)
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | 
    NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents *comps = [cal components:flags fromDate:lastResetDate];
    
    int year = [comps year];
    int month = [comps month];
    int day = [comps day];

    // load the high scores of the day
    NSURL *url = [WordURL getHighScoresURL:year withMonth:month andDay:day];
    
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
    [self showUserScore];
    
    [self togglePlayAgainButton:NO];
    
    // if debug is enabled, setup the expiration time 15 seconds in the future
    if (debugTimer) {
        NSDate *now = [NSDate date];
        debugTimerExpiration = [now dateByAddingTimeInterval:15];
        [debugTimerExpiration retain];
    }

    [self updateTimeLeft];
    
    [self enableTimer];
    [self scheduleLocalNotification];
    
    
    [self loadBestScores];  
    
    if ([scores count] == 0) {
        // show a message if nobody has submitted a score yet today:
        CGRect frame = CGRectMake(80, 80, 150, 100);
        UILabel *noScoresLabel = [[UILabel alloc] initWithFrame:frame];
        noScoresLabel.textColor = [UIColor whiteColor];
        noScoresLabel.backgroundColor = [UIColor clearColor];
        noScoresLabel.text = @"Nobody has solved today's word yet!";
        noScoresLabel.numberOfLines = 3;
        [self.view addSubview:noScoresLabel];
        [noScoresLabel release];
    }

    if (self.bragsEnabled && ![self braggedToday]) { 
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

    //[self updateTimeLeftLabel];
    
    [self.playAgainButton styleWithGradientColor:[HighScoresController highlightColor]];
    
    // log it:    
    [Analytics logEvent:@"High scores shown"];


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

- (int)getSecondsUntilNextPlay {
    // figure out how long until user can play a word:

    NSDate *now = [NSDate date];    
    
    int secondsUntilNextPlay = 0;
    if (debugTimer) {
        // should not be enabled for shipped version, debugging only.
        // pretend remaining time is very short so we can test game rollover.
        secondsUntilNextPlay = (int)[debugTimerExpiration timeIntervalSinceDate:now];
        
    } else {
        // only give them a wait period if they haven't played today's yet.  they
        // might have just finished a previous day's word at this point.
        
        NSDate *lastPlayedDate = [self.gameState lastPlayedDate];
        NSDate *lastResetDate = [TimeUtil getLastResetDate:lastPlayedDate];
        
        // if the last play is before this most recent reset, they can play now.
        // this is the case if someone finishes a previous day's word after the
        // reset:
        
        int diff = (int)[lastResetDate timeIntervalSinceDate:lastPlayedDate];
        if (diff > 0) {
            // last reset is after the last play
            return 0; // allow immediate play.
        }
        
        // so user needs to wait on a countdown until next reset:
        NSDate *nextResetDate = [TimeUtil getNextResetDate:lastPlayedDate];
        
        secondsUntilNextPlay = (int)[nextResetDate timeIntervalSinceDate:now];
    }
    return secondsUntilNextPlay;
    
}


- (NSMutableString *) formatTimeLeft: (int) secsuntilmidnight  {
    int hours = secsuntilmidnight / 3600;
    int remainder = secsuntilmidnight % 3600;
    int minutes = remainder / 60;
    int seconds = remainder % 60;
    
    NSMutableString *timeLeft = [NSMutableString string];
    
    if (hours > 0) { 
        [timeLeft appendFormat:@"%d:%02d:", hours, minutes];
    } else if (minutes > 0) {
        [timeLeft appendFormat:@"%d:", minutes]; 
    } else {
        [timeLeft appendString:@":"];
    }
    
    [timeLeft appendFormat:@"%02d", seconds];
    
    return timeLeft;
}

- (void)enableNextPlay {
    // enable next round of play:

    // disable time countdown.  show play button.
    
    [self.timer invalidate];
    self.timer = nil;
    
    // clear game state and pre-fetch next word
    wordsleuthAppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    [delegate resetGame];
    
    // clear user's score. (issue #46)
    self.lastPlayedNumGuesses = 0;
    [self showUserScore];
    
    [self togglePlayAgainButton:YES];

}


- (void)updateTimeLeft {
    // timer callback.  update the label and then go to a new game if timer
    // is up
    
    //NSLog(@"HSC:updateTimeLeft");
    
    // calculate time until next word is available
    int secondsUntilNextPlay = [self getSecondsUntilNextPlay];
    
    // BDE testing hack:
    //secondsUntilNextPlay = 0;
    
    if (secondsUntilNextPlay <= 0) {
        [self enableNextPlay];
        
    } else {
        // update the time left countdown
        [self updateTimeLeftLabel:secondsUntilNextPlay];
    }
    
}

- (void)updateTimeLeftLabel:(int)secondsUntilNextPlay {
    // iphone date/time library is the poo.. the steaming kind
    
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Play again in just %@!", [self formatTimeLeft: secondsUntilNextPlay]];
}

- (IBAction)pressedPlayAgain:(id)sender {
    
    //NSLog(@"play again pressed");

    // restart the game
    
    wordsleuthAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate startGame];

}

- (BOOL)braggedToday {
    
    if (lastFacebookBragDate == nil)
        return FALSE;
    
    
    NSDate *today = [NSDate date];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:today];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:lastFacebookBragDate];
    
    return [comp1 day] == [comp2 day] &&
           [comp1 month] == [comp2 month] &&
           [comp1 year]  == [comp2 year];
    
}


- (IBAction)facebookBragPressed:(id)sender {
    
    // ask the user if they want to brag on facebook:
    [facebookBragPrompt show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        // brag about score on Facebook
        
        wordsleuthAppDelegate *appDelegate = (wordsleuthAppDelegate *)[[UIApplication sharedApplication] delegate];
         
        [appDelegate.bragFacebook brag:self.lastPlayedNumGuesses];
        
        // save last bragging datetime 
        lastFacebookBragDate = [NSDate date];
        
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setObject:lastFacebookBragDate forKey:@"lastFacebookBragDate"];
        [standardDefaults synchronize];
        
        self.bragLabel.hidden = YES;
        self.facebookBragButton.hidden = YES;
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
    
    [self enableNextPlay];
}

- (void)showUserScore {
    
    if (self.lastPlayedNumGuesses == 0) {
        self.yourScoreLabel.hidden = YES;
    } else {
        self.yourScoreLabel.hidden = NO;
        
        NSString *yourScore = [NSString stringWithFormat:@"Your Score: %d", self.lastPlayedNumGuesses];
        self.yourScoreLabel.text = yourScore;
    }
}

- (void)scheduleLocalNotification {
    // schedule a notification to let user know when the next day's word is available
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification == nil) {
        NSLog(@"scheduleLocalNotification: failed to alloc local notification");
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR

    // simulator, just fire the notification in 30 seconds!
    
    NSTimeInterval secondsFromNow = 15;
    NSDate *now = [NSDate date];
    NSDate *debugFireDate = [now dateByAddingTimeInterval:secondsFromNow];
    
    NSLog(@"debug fire date == %@", debugFireDate);
    notification.fireDate = debugFireDate;
    
#else
    // fire notification when word reset happens:
    NSDate *nextReset = [TimeUtil getNextResetDate:nil];
    NSLog(@"nextReset == %@", nextReset);
    
    notification.fireDate = nextReset;
    
#endif
    
    notification.timeZone = nil; // interprets fire time as an absolute GMT time
    notification.alertBody = @"New word now available!";
    notification.alertAction = @"Play Now";
    notification.soundName = nil;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [notification release];
}

- (void)cancelLocalNotification {
    // cancel scheduled notification about rollover to next day's word
    
    // TODO BDE not used yet!
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in notifs) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}



@end
