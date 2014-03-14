    //
// Created by Marek M on 13.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "AddTaskView+Constraints.h"
#import "MainViewConsts.h"


@implementation AddTaskView (Constraints)

- (void)prepareLayoutConstraints {

    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint * H1WhenShown = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * H1WhenHidden = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:-kAddTaskViewHorizontalMargin];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:kAddTaskViewTopMargin];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:kAddTaskViewHeightFactor
                                                            constant:0.0];

    self.theNewTaskDialogLayoutConstraints = @[H1WhenShown, H2, V1, V2];
    self.theNewTaskDialogLayoutConstraintsForViewBehindTheRightEdge = @[H1WhenHidden, H2, V1, V2];
}

@end