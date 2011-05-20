//
//  UIButton+Gradient.m
//  wordsleuth
//
//  Created by Matthew Botos on 5/19/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "UIButton+Gradient.h"
#import <QuartzCore/QuartzCore.h>


@implementation UIButton (UIButton_Gradient)

- (void) styleWithGradientColor:(UIColor*)color {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.anchorPoint = CGPointMake(0.0f, 0.0f);
    gradient.position = CGPointMake(0.0f, 0.0f);
    gradient.bounds = self.layer.bounds;
    gradient.cornerRadius = 10.0;
    
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    CGFloat red = components[0];
    CGFloat green = components[1]; 
    CGFloat blue = components[2];
    
    CGFloat lightMultiplier = 1.194f;
    CGFloat darkMultiplier = 0.805f;
    
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:lightMultiplier*red
                                           green:lightMultiplier*green
                                            blue:lightMultiplier*blue
                                           alpha:1.0].CGColor,
                       (id)[UIColor colorWithRed:darkMultiplier*red
                                           green:darkMultiplier*green
                                            blue:darkMultiplier*blue
                                           alpha:1.0].CGColor,
                       nil];
    gradient.zPosition = -100.0f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.layer.shadowOpacity = 1.5f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 2.5f;
    [self.layer addSublayer:gradient];     
}


@end
