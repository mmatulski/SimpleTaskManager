//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView+Hints.h"
#import "WrappedButton.h"
#import "PresentationOverlayView+Constraints.h"
#import "TheNewTaskButton.h"
#import "PresentationOverlayView+TheNewTaskDialogHandling.h"
#import "ConfirmationButton.h"
#import "TheNewTaskDialog.h"
#import "CancelButton.h"
#import "UserActionsHelperViewDelegate.h"


@implementation PresentationOverlayView (Hints)

-(void) showOpeningTheNewTaskViewHint{
    self.hintViewForTheNewTask = [[TheNewTaskButton alloc] initWithFrame:CGRectMake(0, 0, 70.0, 30.0)];
    [self.hintViewForTheNewTask setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.hintViewForTheNewTask];

    [self prepareHintViewLayoutsConstraintsForNewTask];

    [self.hintViewForTheNewTask setTarget:self];
    [self.hintViewForTheNewTask setAction:@selector(userDidTapOnTheNewTaskHintView)];
}

- (void)showConfirmationHint {
    if(self.confirmationHintView){
        [self removeConfirmationHintView];
    }

    self.confirmationHintView = [[ConfirmationButton alloc] initWithFrame:CGRectMake(0, 0, 70.0, 30.0)];
    [self.confirmationHintView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.confirmationHintView];

    [self prepareHintViewLayoutsConstraintsForConfirmHint];
    [self addConstraints:_confirmationHintViewLayoutConstraints];

    [self.confirmationHintView setTarget:self];
    [self.confirmationHintView setAction:@selector(userDidTapOnTheConfirmHintView)];
}

- (void)showCancelHint {
    if(self.cancelHintView){
        [self removeCancelHintView];
    }

    self.cancelHintView = [[CancelButton alloc] initWithFrame:CGRectMake(0, 0, 70.0, 30.0)];
    [self.cancelHintView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.cancelHintView];

    [self prepareHintViewLayoutsConstraintsForCancelHint];
    [self addConstraints:_cancelHintViewLayoutConstraints];

    [self.cancelHintView setTarget:self];
    [self.cancelHintView setAction:@selector(userDidTapOnTheCancelHintView)];
}

- (void)userDidTapOnTheNewTaskHintView {
    if([self canShowTheNewTaskDialog]){
        [self userStartsOpeningTheNewTaskDialog];
        [self animatedMovingTheNewTaskDialogToOpenedStatePosition:0.0 completion:NULL];
    }
}

- (void)userDidTapOnTheCancelHintView {
    [self animateClosingTheNewTaskDialogToTheRightEdge];
}

- (void)userDidTapOnTheConfirmHintView {
    if([self.theNewTaskDialog isNameValid]){
        [self.delegate userWantsToSaveTheNewTask:[self.theNewTaskDialog taskName]];
    } else {
        NSString *warningMessage = nil;
        if(![self.theNewTaskDialog isNameValid]){
            warningMessage = @"The task can not be empty";
        }

        [self animatedMovingTheNewTaskDialogToOpenedStatePosition:0.0 completion:^{
            [self showWarningForTheNewTask:warningMessage];
        }];
    }
}


-(void) animatedHintViewForTheNewTaskView:(void (^)(void)) completion{
    if(!self.hintViewForTheNewTask){
        [self showOpeningTheNewTaskViewHint];
    }

    [_widthConstraintForNewTaskHintView setConstant:70];
    [self layoutSubviews];
    [UIView animateWithDuration:0.5 animations:^{
        [_widthConstraintForNewTaskHintView setConstant:110];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [_widthConstraintForNewTaskHintView setConstant:50];
            [self layoutSubviews];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [_widthConstraintForNewTaskHintView setConstant:90];
                [self layoutSubviews];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [_widthConstraintForNewTaskHintView setConstant:70];
                    [self layoutSubviews];
                } completion:^(BOOL finished) {
                    [_widthConstraintForNewTaskHintView setConstant:70];
                    if(completion){
                        completion();
                    }
                }];
            }];
        }];
    }];
}




- (void)prepareHintViewLayoutsConstraintsForNewTask {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                 multiplier:1.0
                                                                                   constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _trailingConstraintForNewTaskHintView = H1;
    _widthConstraintForNewTaskHintView = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:60.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.hintViewForTheNewTask
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _hintViewForTheNewTaskLayoutConstraints = @[H1, H2, V1, V2];
    [self addConstraints:_hintViewForTheNewTaskLayoutConstraints];
}

- (void)prepareHintViewLayoutsConstraintsForConfirmHint {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.confirmationHintView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.confirmationHintView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _leadingConstraintForConfirmationHintView = H1;
    _widthConstraintForConfirmationHintView = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.confirmationHintView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:20.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.confirmationHintView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _confirmationHintViewLayoutConstraints = @[H1, H2, V1, V2];
}

- (void)prepareHintViewLayoutsConstraintsForCancelHint {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.cancelHintView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.cancelHintView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _trailingConstraintForCancelHintView = H1;
    _widthConstraintForCancelHintView = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.cancelHintView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:20.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.cancelHintView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _cancelHintViewLayoutConstraints = @[H1, H2, V1, V2];
}

- (void)removeConfirmationHintView {
    [self.confirmationHintView removeFromSuperview];
    if(_confirmationHintViewLayoutConstraints){
        [self removeConstraints:_confirmationHintViewLayoutConstraints];
    }
    self.confirmationHintView = nil;
}

- (void)removeCancelHintView {
    [self.cancelHintView removeFromSuperview];
    if(_cancelHintViewLayoutConstraints){
        [self removeConstraints:_cancelHintViewLayoutConstraints];
    }
    self.cancelHintView = nil;
}

@end