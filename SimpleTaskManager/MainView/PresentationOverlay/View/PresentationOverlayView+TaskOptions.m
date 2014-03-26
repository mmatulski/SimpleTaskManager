//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView+TaskOptions.h"
#import "TaskOptionsView.h"
#import "MainViewConsts.h"

@implementation PresentationOverlayView (TaskOptions)

- (BOOL)isTaskOptionsViewShown {
    return self.taskOptionsView.superview != nil;
}

#pragma mark Showing/Closing methods

- (void)showTaskOptionsForCellWithFrame:(CGRect)cellFrame animated:(BOOL)animated {
    BOOL alreadyShown = false;
    [self prepareOptionsViewAndCheckIfAlreadyShown:&alreadyShown];

    _taskOptionsViewFirstTopY = [self estimateTopPositionForOptionsViewUsingCellFrame:cellFrame];

    if(alreadyShown){
        [self moveOptionsViewToTopPosition:_taskOptionsViewFirstTopY animated:animated];
    } else {
        //first move options to last correct position wihtout animation
        [self moveOptionsViewToTopPosition:_taskOptionsViewFirstTopY animated:false];
        [self makeOptionsViewVisibleAnimated:animated];
    }
}

- (void)moveOptionsViewToTopPosition:(CGFloat)y animated:(BOOL)animated {
    if(animated){
        _taskOptionsHeightLayoutConstraint.constant = kOptionsViewHeight;
        [self layoutIfNeeded];

        BlockWeakSelf selfWeak = self;
        [UIView animateWithDuration:kMoveOptionsAnimationDuration animations:^{
            [_taskOptionsTopLayoutConstraint setConstant:y];
            [selfWeak layoutIfNeeded];
        }                completion:^(BOOL finished) {

        }];
    } else {
        [_taskOptionsTopLayoutConstraint setConstant:y];
        [self layoutIfNeeded];
    }
}

- (void)closeTaskOptionsAnimated:(BOOL)animated {
    if(animated){
        BlockWeakSelf selfWeak = self;
        [UIView animateWithDuration:kCloseOptionsAnimationDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            [_taskOptionsHeightLayoutConstraint setConstant:0.0];
            [selfWeak layoutIfNeeded];
        }                completion:^(BOOL finished) {
            [selfWeak removeTaskOptionsView];
        }];
    } else {
        [self removeTaskOptionsView];
    }
}

#pragma mark -

- (void) prepareOptionsViewAndCheckIfAlreadyShown:(BOOL *)alreadyShown {
    BOOL result = false;
    if(!self.taskOptionsView){
        [self prepareTaskOptionsView];
    }

    if(self.taskOptionsView.superview){
        result = true;
    } else {
        [self addSubview:self.taskOptionsView];
    }

    if(!_taskOptionsLayoutConstraints){
        [self prepareTaskOptionsViewLayoutConstraints];
    }

    [self addTaskOptionsViewConstraints];

    *alreadyShown = result;
}

- (CGFloat)estimateTopPositionForOptionsViewUsingCellFrame:(CGRect)cellFrame {
    CGRect localCellFrame = [self convertRect:cellFrame fromView:nil];

    return localCellFrame.origin.y + localCellFrame.size.height;
}

- (void)makeOptionsViewVisibleAnimated:(BOOL)animated {
    if(animated){
        [self layoutIfNeeded];

        BlockWeakSelf selfWeak = self;
        [UIView animateWithDuration:kShowOptionsAnimationDuration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            [selfWeak makeOptionsViewVisible];
        }                completion:^(BOOL finished) {

        }];
    } else {
        [self makeOptionsViewVisible];
    }
}

- (void)makeOptionsViewVisible {
    [_taskOptionsHeightLayoutConstraint setConstant:kOptionsViewHeight];
    [self layoutIfNeeded];
}

- (void)removeTaskOptionsView {
    [self removeTaskOptionsViewConstraints];
    [self.taskOptionsView removeFromSuperview];
    self.taskOptionsView = nil;
    _taskOptionsLayoutConstraints = nil;
}

- (void)addTaskOptionsViewConstraints {
    if(_taskOptionsLayoutConstraints){
        [self.taskOptionsView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:_taskOptionsLayoutConstraints];
    }
}

-(void) removeTaskOptionsViewConstraints{
    if(_taskOptionsLayoutConstraints){
        [self removeConstraints:_taskOptionsLayoutConstraints];
    }
}

- (void)prepareTaskOptionsView {
    self.taskOptionsView = [[TaskOptionsView alloc] initWithFrame:CGRectZero];
}

- (void)prepareTaskOptionsViewLayoutConstraints {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.taskOptionsView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.taskOptionsView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:-20];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.taskOptionsView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.taskOptionsView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];//first always is 0 height

    _taskOptionsTopLayoutConstraint = V1;
    _taskOptionsHeightLayoutConstraint = V2;

    _taskOptionsLayoutConstraints = @[H1, H2, V1, V2];
}



@end