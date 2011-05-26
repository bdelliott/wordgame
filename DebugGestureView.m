//
//  DebugGestureView.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 5/25/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "DebugGestureView.h"


@implementation DebugGestureView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;

        gestureState = DEBUG_GESTURE_NONE;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    gestureState = DEBUG_GESTURE_NONE;
    
    // multi touch is disabled, so only one touch will come at a time
    assert([touches count] == 1);

    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    // touch must begin in the bottom left part of the screen:
    
    if (pt.x < 100 && pt.y >= 300) {
        NSLog(@"touchBegan: debug gesture started");
        gestureState = DEBUG_GESTURE_STARTED;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    // multi touch is disabled, so only one touch will come at a time
    assert([touches count] == 1);
    
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    if (gestureState == DEBUG_GESTURE_STARTED) {
        // touch must move to the upper left part of the scren to continue
        // the gesture

        if (pt.x < 100 && pt.y <= 150) {
            NSLog(@"touchesMoved: debug gesture turned");
            gestureState = DEBUG_GESTURE_TURN;
        }
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    if (gestureState == DEBUG_GESTURE_TURN) {
        // touch must finish in the upper right part of the screen to 
        // complete the gesture
        
        if (pt.x > 225 && pt.y <= 150) {
            NSLog(@"touchesEnded: debug gesture completed");
            
            // invoke delegate callback -
            [delegate debugGestureDetected];
        }
        
    } 
    
    // clear state
    gestureState = DEBUG_GESTURE_NONE;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
    gestureState = DEBUG_GESTURE_NONE;
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)dealloc
{
    [self.delegate release];
    delegate = nil;
    
    [super dealloc];
}

@end
