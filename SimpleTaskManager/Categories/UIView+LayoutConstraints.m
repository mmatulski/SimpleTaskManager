//
// Created by Marek M on 13.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "UIView+LayoutConstraints.h"


@implementation UIView (LayoutConstraints)

- (CGRect)estimateFrameWithConstraints:(NSArray *)constraints {
    CGRect result = CGRectZero;
    if(constraints){
        CGRect frameBefore = self.frame;
        [self.superview addConstraints:constraints];
        [[self superview] layoutSubviews];
        result = self.frame;
        [self.superview removeConstraints:constraints];
        [[self superview] layoutSubviews];

        self.frame = frameBefore;
    }
    return result;
}

@end