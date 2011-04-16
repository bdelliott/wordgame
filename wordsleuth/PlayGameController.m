//
//  FirstViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "PlayGameController.h"


@implementation PlayGameController

@synthesize numGuesses;
@synthesize guesses;

@synthesize word;

@synthesize guessTextField;
@synthesize numGuessesLabel;
@synthesize beforeTextField;
@synthesize afterTextField;

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    if (self) {
       
        word = @"nacho";

        numGuesses = 0;
        closestBeforeGuess = nil;
        closestAfterGuess = nil;
        
        guesses = [NSMutableArray arrayWithCapacity:32];
        [guesses retain];
        
    }
    return self;
    
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"PlayGameController: viewDidLoad");
    [super viewDidLoad];

    
    numGuessesLabel.text = [NSString stringWithFormat:@"%d guesses so far:", numGuesses];
    beforeTextField.text = @"";
    afterTextField.text = @"";
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
    [super dealloc];
}

- (IBAction)guessMade:(id)sender {
    NSLog(@"user made a guess and dismissed keyboard");
    
    [guessTextField resignFirstResponder];
    
    NSString *guess = guessTextField.text;
    guess = [guess lowercaseString];

    NSLog(@"user guessed '%@'", guess);
    
    [self checkGuess:guess];
    
}

- (void)checkGuess:(NSString *)guess {
    
    BOOL wrong = FALSE;
    
    [guesses addObject:guess];
    numGuesses++;
    
    if (numGuesses == 1) {
        
        self.numGuessesLabel.text = @"1 guess so far:";
    } else {
        self.numGuessesLabel.text = [NSString stringWithFormat:@"%d guesses so far:", numGuesses];
        
    }

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
        }
    }
    
    afterTextField.text = closestAfterGuess;
}

- (void)guessIsCorrect {
    // do all the you-win stuff.
    NSLog(@"winner winner chicken dinner");
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger row = indexPath.row;
    NSString *cellId = [NSString stringWithFormat:@"guess%d", row];
    NSLog(@"cellId==%@", cellId);
                        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    cell.textLabel.text = [guesses objectAtIndex:indexPath.row];
    
    //cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"numberOfRowsInSection");
    return [guesses count];
}

@end
