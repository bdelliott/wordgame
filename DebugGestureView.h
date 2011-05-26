//
//  DebugGestureView.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 5/25/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEBUG_GESTURE_NONE 0
#define DEBUG_GESTURE_STARTED 1
#define DEBUG_GESTURE_TURN 2

@protocol DebugViewDelegate

-(void) debugGestureDetected;

@end

@interface DebugGestureView : UIView {

    NSInteger gestureState;
}

@property (nonatomic, retain) NSObject<DebugViewDelegate> *delegate;

@end
