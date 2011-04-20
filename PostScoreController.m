//
//  PostScoreController.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/19/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "PostScoreController.h"
#import "ASIFormDataRequest.h"
#import "wordsleuthAppDelegate.h"
#import "HighScoresController.h"

@implementation PostScoreController

@synthesize numGuesses;
@synthesize word;

@synthesize userNameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [userNameTextField becomeFirstResponder];
    }
    return self;
}

- (void)dealloc
{
    [userNameTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setUserNameTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)postButtonClicked:(id)sender {
    NSLog(@"post button clicked");
    
    NSString *userName = [userNameTextField text];
    
    NSString *postUrl = [NSString stringWithFormat:@"http://localhost:8000/service/post_score/%@", userName];
    NSURL *url = [NSURL URLWithString:postUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *numGuessStr = [NSString stringWithFormat:@"%d", numGuesses];
    
    [request setPostValue:numGuessStr forKey:@"num_guesses"];
    [request setPostValue:word forKey:@"word"];
    
    [request startSynchronous];
    
    
    NSError *error = [request error];
    if (error || [request responseStatusCode] != 200) {
        // score post failed
        NSLog(@"score post failed");
        
    } else {
        
        // score posted, get high scores
        HighScoresController *highScoresController =
        [[HighScoresController alloc] initWithNibName:@"HighScores" bundle:nil];
        
        wordsleuthAppDelegate *delegate = (wordsleuthAppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.window.rootViewController = highScoresController;
        
        
    }
    
    
}

@end
