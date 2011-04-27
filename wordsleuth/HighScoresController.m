//
//  SecondViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "HighScoresController.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "WordURL.h"

@implementation HighScoresController

@synthesize highScoresTableView;

+ (UIColor*) highlightColor {
    return [UIColor colorWithRed:.91f green:.67f blue:.15f alpha:1.0f];
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self)
        return nil;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Best Scores";

    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FullBackground.png"]];
    self.highScoresTableView.backgroundColor = [UIColor clearColor];
    
    self.highScoresTableView.rowHeight = 34.0f;

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
    }  
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
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [highScoresTableView release];
    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId = @"ScoreCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [HighScoresController highlightColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:cell.detailTextLabel.font.pointSize];
    }
    
    NSDictionary *score = [scores objectAtIndex:indexPath.row];
    NSString *playerName = [score objectForKey:@"user_name"];
    NSDecimalNumber *numGuesses = [score objectForKey:@"num_guesses"];
    cell.textLabel.text = playerName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", numGuesses];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"numberOfRowsInSection, %d rows", [scores count]);
    return [scores count];
}


@end
