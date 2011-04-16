//
//  SecondViewController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "HighScoresController.h"


@implementation HighScoresController

@synthesize highScores;
@synthesize highScoresTableView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hack up some fake high scores data
    
    highScores = [NSMutableArray arrayWithCapacity:10];
    [highScores retain];
    
    NSMutableArray *p1 = [NSMutableArray arrayWithCapacity:2];
    [p1 addObject:@"Bob"];
    [p1 addObject:@"8 guesses"];
    [highScores addObject:p1];

    NSMutableArray *p2 = [NSMutableArray arrayWithCapacity:2];
    [p2 addObject:@"Brian"];
    [p2 addObject:@"10 guesses"];
    [highScores addObject:p2];

    NSMutableArray *p3 = [NSMutableArray arrayWithCapacity:2];
    [p3 addObject:@"Cassandra"];
    [p3 addObject:@"15 guesses"];
    [highScores addObject:p3];

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
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NSArray *score = [highScores objectAtIndex:indexPath.row];
    NSString *playerName = [score objectAtIndex:0];
    NSString *numGuesses = [score objectAtIndex:1];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@    %@", playerName, numGuesses];
    
    //cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"numberOfRowsInSection");
    return [highScores count];
}


@end
