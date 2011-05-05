//
//  wordsleuthAppDelegate.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "wordsleuthAppDelegate.h"
#import "HighScoresController.h"

@implementation wordsleuthAppDelegate


@synthesize window=_window;

@synthesize navigationController = _navigationController;

@synthesize playGameController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.navigationController;
    
    // first check if the user has already played today:
    BOOL playedToday = [self checkPlayedToday];
    
    // todo remove
    if (playedToday) {
        // skip to high scores screen with timer
        [HighScoresController goToHighScores];
        
    } else {
        // user has not played today:
        playGameController = [[PlayGameController alloc] initWithNibName:@"PlayGame" bundle:nil];
        
        [self.navigationController pushViewController:playGameController animated:TRUE];
        
    }
    
    

    
    /*self.navigationController.navigationBar.topItem.title = @"Word du Jour";
    self.navigationController.navigationBar.topItem.hidesBackButton = YES;
    */
    [self.window makeKeyAndVisible];
    return YES;
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

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

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
