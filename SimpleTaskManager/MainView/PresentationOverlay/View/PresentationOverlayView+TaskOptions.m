//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView+TaskOptions.h"
#import "TaskOptionsView.h"
#import "MainViewConsts.h"

@implementation PresentationOverlayView (TaskOptions)

- (void)showTaskOptionsViewForCell:(UITableViewCell *)cell animated:(BOOL)animated {
    BOOL alreadyShown = false;
    if(!self.taskOptionsView){
        [self prepareTaskOptionsView];
    }

    if(self.taskOptionsView.superview){
        alreadyShown = true;
    } else {
        [self addSubview:self.taskOptionsView];
    }

    if(!_taskOptionsLayoutConstraints){
        [self prepareTaskOptionsViewLayoutConstraints];
    }

    [self addTaskOptionsViewConstraints];

    _taskOptionsViewFirstTopY = [self estimateTopPositionOfOptionsViewForCell:cell];

    if(alreadyShown){
        [self moveOptionsViewToTopPosition:_taskOptionsViewFirstTopY animated:animated ];
    } else {
        [self moveTaskOptionsViewToTop:_taskOptionsViewFirstTopY];
        [self showOptionsViewAnimated:animated ];
    }
}

- (void)moveOptionsViewToTopPosition:(CGFloat)y animated:(BOOL)animated {
    if(animated){
        _taskOptionsHeightLayoutConstraint.constant = kOptionsViewHeight;
        [self layoutSubviews];
        [UIView animateWithDuration:0.2 animations:^{
            [_taskOptionsTopLayoutConstraint setConstant:y];
            [self layoutSubviews];
        } completion:^(BOOL finished) {

        }];
    } else {
        [_taskOptionsTopLayoutConstraint setConstant:y];
        [self layoutSubviews];
    }

}

- (void)closeTaskOptions {
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [_taskOptionsHeightLayoutConstraint setConstant:0.0];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [self removeTaskOptionsView];
    }];
}

- (void)updateTaskOptionsForTaskBecauseItWasScrolledBy:(CGFloat)change {
    [self moveTaskOptionsViewToTop:_taskOptionsViewFirstTopY + change];
}

- (void)removeTaskOptionsView {
    [self removeTaskOptionsViewConstraints];
    [self.taskOptionsView removeFromSuperview];
    self.taskOptionsView = nil;
    _taskOptionsLayoutConstraints = nil;
}

- (void)showOptionsViewAnimated:(BOOL)animated {
    if(animated){
        [self layoutIfNeeded];

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            [_taskOptionsHeightLayoutConstraint setConstant:kOptionsViewHeight];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {

        }];
    } else {
        [_taskOptionsHeightLayoutConstraint setConstant:kOptionsViewHeight];
        [self layoutIfNeeded];
    }
}

- (CGFloat)estimateTopPositionOfOptionsViewForCell:(UITableViewCell *)cell {
    UIView * parentViewOfCell = cell.superview;
    CGRect cellFrameRelatingToTheWindows = [parentViewOfCell convertRect:cell.frame toView:nil];
    CGRect cellFrame = [self convertRect:cellFrameRelatingToTheWindows fromView:nil];

    return cellFrame.origin.y + cellFrame.size.height;
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

- (void)moveTaskOptionsViewToTop:(CGFloat)y {
    [_taskOptionsTopLayoutConstraint setConstant:y];
    [self layoutSubviews];
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

- (BOOL)isShowingTaskOptionsView {
    return self.taskOptionsView.superview != nil;
}

@end