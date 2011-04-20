//
//  SecondViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "HighScoresController.h"
#import "ASIHTTPRequest.h"


@implementation HighScoresController

@synthesize highScoresTableView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load the high scores of the day
    NSURL *url = [NSURL URLWithString:@"http://localhost:8000/service/get_scores"];
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
    
    NSUInteger row = indexPath.row;
    NSString *cellId = [NSString stringWithFormat:@"highscore%d", row];
    NSLog(@"cellId==%@", cellId);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellId];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NSDictionary *score = [scores objectAtIndex:indexPath.row];
    NSString *playerName = [score objectForKey:@"user_name"];
    NSDecimalNumber *numGuesses = [score objectForKey:@"num_guesses"];
    cell.textLabel.text = playerName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", numGuesses];
    
    //cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"numberOfRowsInSection, %d rows", [scores count]);
    return [scores count];
}


@end
