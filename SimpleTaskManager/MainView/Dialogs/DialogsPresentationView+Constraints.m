//
// Created by Marek M on 13.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogsPresentationView+Constraints.h"

@implementation DialogsPresentationView (Constraints)

- (void)prepareLayoutConstraints {

    NSLayoutConstraint * H1 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];
    self.cachedLayoutConstraints = @[H1, H2, V1, V2];
}

@end