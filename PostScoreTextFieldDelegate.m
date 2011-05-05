//
//  PostScoreTextFieldDelegate.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 5/5/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "PostScoreTextFieldDelegate.h"


@implementation PostScoreTextFieldDelegate 

@synthesize alertView;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSLog(@"PostScoreTextFieldDelegate:textFieldShouldReturn");
    NSString *userName = [textField text];
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end

