//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DPView+TheNewTaskDialogHandling.h"
#import "MainViewConsts.h"
#import "AddTaskView.h"
#import "CGEstimations.h"


@implementation DPView (TheNewTaskDialogHandling)

- (void)prepareTheNewTaskDialogLayoutConstraints {

    [self.theNewTaskDialog setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint * H1WhenShown = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0];

    NSLayoutConstraint * H1WhenHidden = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:-kAddTaskViewHorizontalMargin];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:kAddTaskViewTopMargin];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:kAddTaskViewHeightFactor
                                                            constant:0.0];

    self.theNewTaskDialogLayoutConstraintsWhenOpened = @[H1WhenShown, H2, V1, V2];
    self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge = @[H1WhenHidden, H2, V1, V2];
}

- (void)userStartsOpeningTheNewTaskDialog {
    [self prepareTheNewTaskDialog];
    [self moveTheNewTaskDialogBehindTheRightEdge];

    _originalPositionOfTheNewTaskDialogBeforeMoving = self.theNewTaskDialog.center;
}

- (void)prepareTheNewTaskDialog {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;

    self.theNewTaskDialog = [[AddTaskView alloc] initWithFrame:CGRectMake(0, 44, 100, 100)];
    [self addSubview:self.theNewTaskDialog];
    [self prepareTheNewTaskDialogLayoutConstraints];
}

- (void)moveTheNewTaskDialogBehindTheRightEdge {
    [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
    [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
    [self layoutSubviews];
}

- (void)userMovesTheNewTaskDialogByX:(CGFloat)x{
    CGPoint changedPosition = _originalPositionOfTheNewTaskDialogBeforeMoving;
    changedPosition.x += x;

    self.theNewTaskDialog.center = changedPosition;
}

- (void)userEndsMovingDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    if([self shouldOpenTheNewTaskDialogForTranslation:translation andVelocity:velocity]){
        CGFloat vectorLength = [CGEstimations pointDistanceToCenterOfAxis:velocity];
        [self animatedMovingTheNewTaskDialogToOpenedStatePosition:vectorLength];

    } else {
        [self animatedClosingTheNewTaskDialog];
    }
}

- (void)userCancelsMovingTheNewTaskDialog {
    [self animatedClosingTheNewTaskDialog];
}

- (BOOL)shouldOpenTheNewTaskDialogForTranslation:(CGPoint)translation andVelocity:(CGPoint)velocity {

    //if velocity is greater than zero it means the direction in to right edge
    // 10.0 is the value which is safe to eliminate the case when User stops moving his finger
    if(velocity.x > 10.0){
        return false;
    }

    //if User will not
    if(translation.x > -40.0){
        return false;
    }

    return true;
}

- (void)animatedMovingTheNewTaskDialogToOpenedStatePosition:(CGFloat)strength {

    CGFloat animationDuration = 1.0f *  500.0 / (strength>0?strength:500.0);

    if(animationDuration > 0.7){
        animationDuration = 0.7;
    }

    [UIView animateWithDuration:animationDuration animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
    }];
}

- (void)animatedClosingTheNewTaskDialog {
    [UIView animateWithDuration:0.7 animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [self removeTheNewTaskView];
    }];
}

- (void)removeTheNewTaskView {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;
}

@end