//
//  GameState.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 7/20/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_FETCH_FAILS 5

typedef enum {
    
    WordCompareBefore,      // guess is new "before" word
    WordCompareExact,       // guess was correct
    WordCompareAfter,       // guess is new "after" word
    WordCompareNoUpdate,    // guess was incorrect, but not closer than prev guesses
    
} WordComparison;


@interface GameState : NSObject {
    
    BOOL hasPlayedToday;
    int lastPlayedNumGuesses;
    
    NSString *word; // word being played
    NSDate *wordDate; // date of word being played
    
    NSString *closestBeforeGuess;
    NSString *closestAfterGuess;
    NSMutableArray *guesses;
    
    // for background word fetching:
    int numFetchFails;
}

@property (nonatomic, assign) BOOL hasPlayedToday;

@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSDate *wordDate;

@property (nonatomic, retain) NSMutableArray *guesses;
@property (nonatomic, retain) NSString *closestBeforeGuess;
@property (nonatomic, retain) NSString *closestAfterGuess;

- (WordComparison)checkGuess:(NSString *)guess;

- (WordComparison)guessBeforeWord:(NSString *)guess;
- (WordComparison)guessAfterWord:(NSString *)guess;

- (void)doFetchWord; // private
- (void)fetchWord;
- (NSDate *) wordDateFromDict:(NSDictionary *)dictionary;

- (BOOL)hasPlayedToday;
- (NSDate *) lastPlayedDate;

- (int)lastPlayedNumGuesses;
- (int)numGuesses;

- (void)resetGame;

- (NSString *)getSavedUserName;
- (void)saveUserName:(NSString *)userName;
- (void)saveLastPlayed:(int)numGuesses;


@end
