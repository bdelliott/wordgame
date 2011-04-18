//
//  wordsleuthAppDelegate.h
//  wordsleuth
//
//  Created by Brian D. Elliott on 4/14/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wordsleuthAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

    UINavigationController *_navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@end
