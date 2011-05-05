//
//  PostScoreTextFieldDelegate.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 5/5/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSAlertView.h"

@interface PostScoreTextFieldDelegate : NSObject <UITextFieldDelegate> {
    TSAlertView *alertView;
}

@property (nonatomic, retain) TSAlertView *alertView;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
