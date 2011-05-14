//
//  wordsleuthAppDelegate.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "wordsleuthAppDelegate.h"
#import "HighScoresController.h"
#import "Launch.h"

NSString* const GameStateLoaded = @"GameStateLoaded";


@implementation wordsleuthAppDelegate

@synthesize window=_window;

@synthesize navigationController = _navigationController;

@synthesize playGameController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = [[[Launch alloc] init] autorelease];
    
    [NSThread detachNewThreadSelector:@selector(loadGameState) toTarget:self withObject:nil];
    
    [self.window makeKeyAndVisible];
    
    launchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(launchDisplayCompleted) userInfo:nil repeats:NO];

    return YES;
}

- (void) launchDisplayCompleted {
    launchDisplayCompleted = YES;
    [self loadGameView];
}

- (void) loadGameState {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // first check if the user has already played today:
    playedToday = [self checkPlayedToday];
    hasGameState = YES;
    
    // BDE egregious testing hack:
    //playedToday = NO;
    
    // all calls to UIKit must be from main thread
    [self performSelectorOnMainThread:@selector(loadGameView) withObject:nil waitUntilDone:NO];
    
    [pool release];
}

- (void) loadGameView {
    if (hasGameState && launchDisplayCompleted) {
        self.window.rootViewController = self.navigationController;
        
        if (playedToday) {
            // skip to high scores screen with timer
            NSLog(@"User already played today, going to high scores.");
            [HighScoresController goToHighScores];            
        } else {
            NSLog(@"User has not played yet today, initializing game.");
            [self startGame];            
        }
    }
}

- (void)startGame {

    NSLog(@"wordsleuth:startGame");
    if (!self.playGameController) {
        // user has not played today:
        self.playGameController = [[PlayGameController alloc] initWithNibName:@"PlayGame" bundle:nil];
        [self.navigationController pushViewController:self.playGameController animated:TRUE];
    }
    
    [self.navigationController popToViewController:self.playGameController animated:TRUE];

}




- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [playGameController release];
    [super dealloc];
}

- (BOOL)checkPlayedToday {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // get last played date
    NSDate *lastPlayed = [standardUserDefaults objectForKey:@"lastPlayed"];
    NSLog(@"Game last played on: %@", lastPlayed);
    
    if (!lastPlayed) {
        // user has never played
        return FALSE;
    }
    
    // get current date/time
    NSDate *now = [NSDate date]; // returns the UTC date/time
    
    // test if the two are the same day using the truly odd
    // NSCalendar and NSDateComponent classes!  could they make
    // this any uglier?
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned uglyDateComponentOrBits = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *lastComponents = [cal components:uglyDateComponentOrBits fromDate:lastPlayed];
    NSDateComponents *nowComponents = [cal components:uglyDateComponentOrBits fromDate:now];
    
    NSInteger lastYear = [lastComponents year];
    NSInteger lastMonth = [lastComponents month];
    NSInteger lastDay = [lastComponents day];
    
    NSInteger nowYear = [nowComponents year];
    NSInteger nowMonth = [nowComponents month];
    NSInteger nowDay = [nowComponents day];
    
    if (lastYear != nowYear)
        return FALSE;
    if (lastMonth != nowMonth)
        return FALSE;
    return (lastDay == nowDay);
    
}


@end
