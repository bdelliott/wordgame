//
//  GameState.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/16/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "GameState.h"
#import "Notifications.h"
#import "NSString+SBJSON.h"
#import "WordURL.h"


@implementation GameState

@synthesize hasPlayedToday;

@synthesize guesses;
@synthesize closestBeforeGuess;
@synthesize closestAfterGuess;

@synthesize word;

- (id)init {
    
    self = [super init];
    if (self) {
        hasPlayedToday = [self hasPlayedToday];
        lastPlayedNumGuesses = [self lastPlayedNumGuesses];
        
    }
    
    return self;
}

- (void)dealloc {
    
    [word release];
    [guesses removeAllObjects];
    [guesses release];
    
    [closestBeforeGuess release];
    [closestAfterGuess release];
    
    [super dealloc];
}

- (void)resetGame {
    // reset state for a new game -- new word fetch should already be in progress.
    closestBeforeGuess = nil;
    closestAfterGuess = nil;
    
    [self.guesses removeAllObjects];
    self.guesses = [NSMutableArray array];
    
    [self fetchWord];
}

- (void)fetchWord {
    
    // load the word of the day in a background thread.
    self.word = nil;
    [NSThread detachNewThreadSelector:@selector(doFetchWord) toTarget:self withObject:nil];
    
}


- (void)doFetchWord {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    numFetchFails = 0;
    
    NSURL *url = [WordURL getWordURL];
    
    while (numFetchFails < MAX_FETCH_FAILS) {
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request startSynchronous];
        NSError *error = [request error];
        
        if (error) {
            numFetchFails++;
            NSLog(@"word load failed, error=%@", error);
            
            [NSThread sleepForTimeInterval:0.2] ;// sleep for 200 ms before we try the fetch again.
            
        } else {
            NSString *response = [request responseString];
            NSLog(@"response==%@", response);
            NSDictionary *dictionary = [response JSONValue];
            
            self.word = [dictionary objectForKey:@"word"];
            
            NSLog(@"Finished loading word: %@", word);
            break;
        }
        
    }
    
    // alert that background fetch is complete.
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WORD_FETCH_DONE object:nil];
    
    [pool release];
}

- (WordComparison)checkGuess:(NSString *)guess {
    
    [guesses addObject:guess];
    
    // compare to our magic word
    NSComparisonResult cmp = [self.word localizedCaseInsensitiveCompare:guess];

    switch (cmp) {
        case NSOrderedAscending:
            // word is before guess
            return [self guessAfterWord:guess];
            break;
            
        case NSOrderedSame:
            // user guessed right
            return WordCompareExact;
            
        case NSOrderedDescending:
            // word is after guess
            return [self guessBeforeWord:guess];
            break;
            
        default:
            NSLog(@"GameState:checkGuess: %@ WTF", guess);
            return WordCompareNoUpdate;
    }

}

- (WordComparison)guessBeforeWord:(NSString *)guess {
    // compare to previous closest "before" guess
    
    if (!closestBeforeGuess) {
        closestBeforeGuess = guess;
        return WordCompareBefore;
    } else {
        
        NSComparisonResult cmp = [closestBeforeGuess localizedCaseInsensitiveCompare:guess];
        if (cmp == NSOrderedAscending) {
            NSLog(@"%@ is after previous closest 'before' guess %@", guess, closestBeforeGuess);
            closestBeforeGuess = guess;
            return WordCompareBefore;
        } else {
            return WordCompareNoUpdate;
        }
        
    }
    
}

- (WordComparison)guessAfterWord:(NSString *)guess {
    // compare to previous closest "after" guess
    
    if (!closestAfterGuess) {
        closestAfterGuess = guess;
        return WordCompareAfter;
        
    } else {
        NSComparisonResult cmp = [closestAfterGuess localizedCaseInsensitiveCompare:guess];
        if (cmp == NSOrderedDescending) {
            NSLog(@"%@ is before previous closest 'after' guess %@", guess, closestAfterGuess);
            closestAfterGuess = guess;
            return WordCompareAfter;
        } else {
            return WordCompareNoUpdate;
        }
    }
    
}



- (BOOL)hasPlayedToday {
    
    // BDE egregious testing hack:
    // return NO;
    
    
    NSDate *lastPlayed;
    lastPlayed = [self lastPlayedDate];
    
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

- (NSDate *) lastPlayedDate {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"lastPlayed"];
}

- (int)lastPlayedNumGuesses {
    // number of guesses from last game completed
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // returns 0 if int not found.
    int num = [standardUserDefaults integerForKey:@"lastPlayedNumGuesses"];
    return num;
}

- (int)numGuesses {
    // number of guesses in current game in progress
    return [self.guesses count];
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

