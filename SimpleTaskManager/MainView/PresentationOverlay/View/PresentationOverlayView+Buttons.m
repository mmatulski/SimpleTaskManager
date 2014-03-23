//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView+Buttons.h"
#import "WrappedButton.h"
#import "PresentationOverlayView+Constraints.h"
#import "TheNewTaskButton.h"
#import "PresentationOverlayView+TheNewTaskDialogHandling.h"
#import "SaveNewTaskButton.h"
#import "TheNewTaskDialog.h"
#import "CancelButton.h"
#import "PresentationOverlayViewDelegate.h"


@implementation PresentationOverlayView (Buttons)

#pragma mark - Showing buttons

-(void)showNewTaskButton {
    self.theNewTaskButton = [[TheNewTaskButton alloc] initWithFrame:CGRectZero];
    [self addSubview:self.theNewTaskButton];

    [self prepareNewTaskButtonLayoutsConstraints];
    [self.theNewTaskButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:_theNewTaskButtonLayoutConstraints];

    [self.theNewTaskButton setTarget:self];
    [self.theNewTaskButton setAction:@selector(userDidTapOnNewTaskButton)];
}

- (void)showSaveNewTaskButton {
    if(self.saveNewTaskButton){
        [self removeSaveNewTaskButton];
    }

    self.saveNewTaskButton = [[SaveNewTaskButton alloc] initWithFrame:CGRectZero];
    [self addSubview:self.saveNewTaskButton];

    [self prepareSaveNewTaskButtonLayoutConstraints];
    [self.saveNewTaskButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:_saveNewTaskButtonLayoutConstraints];

    [self.saveNewTaskButton setTarget:self];
    [self.saveNewTaskButton setAction:@selector(userDidTapOnSaveNewTaskButton)];
}

- (void)showCancelNewTaskButton {
    if(self.cancelNewTaskButton){
        [self removeCancelTaskButton];
    }

    self.cancelNewTaskButton = [[CancelButton alloc] initWithFrame:CGRectZero];
    [self addSubview:self.cancelNewTaskButton];

    [self prepareCancelNewTaskButtonLayoutsConstraints];
    [self.cancelNewTaskButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:_cancelNewTaskButtonLayoutConstraints];

    [self.cancelNewTaskButton setTarget:self];
    [self.cancelNewTaskButton setAction:@selector(userDidTapOnCancelNewTaskButton)];
}

#pragma marl - Hiding buttons

- (void)removeSaveNewTaskButton {
    [self.saveNewTaskButton removeFromSuperview];
    if(_saveNewTaskButtonLayoutConstraints){
        [self removeConstraints:_saveNewTaskButtonLayoutConstraints];
    }
    self.saveNewTaskButton = nil;
}

- (void)removeCancelTaskButton {
    [self.cancelNewTaskButton removeFromSuperview];
    if(_cancelNewTaskButtonLayoutConstraints){
        [self removeConstraints:_cancelNewTaskButtonLayoutConstraints];
    }
    self.cancelNewTaskButton = nil;
}

#pragma mark - Actions

- (void)userDidTapOnNewTaskButton {
    if([self canShowNewTaskDialog]){
        [self userStartsOpeningNewTaskDialog];
        [self animatedMovingNewTaskDialogToOpenedStatePosition:0.0 completion:NULL];
    }
}

- (void)userDidTapOnSaveNewTaskButton {
    if([self.theNewTaskDialog isNameValid]){
        [self.delegate userWantsToSaveTheNewTask:[self.theNewTaskDialog taskName]];
    } else {
        [self animateNewTaskViewBackToOpenedPositionWithWarning];
    }
}

- (void)userDidTapOnCancelNewTaskButton {
    [self animateClosingTheNewTaskDialogToTheRightEdge];
}

#pragma mark - Layout constraints

- (void)prepareNewTaskButtonLayoutsConstraints {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.theNewTaskButton
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                 multiplier:1.0
                                                                                   constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.theNewTaskButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _trailingConstraintForNewTaskButton = H1;
    _widthConstraintForNewTaskButton = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.theNewTaskButton
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:60.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.theNewTaskButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _theNewTaskButtonLayoutConstraints = @[H1, H2, V1, V2];
}

- (void)prepareSaveNewTaskButtonLayoutConstraints {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.saveNewTaskButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.saveNewTaskButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _leadingConstraintForSaveNewTaskButton = H1;
    _widthConstraintForSaveNewTaskButton = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.saveNewTaskButton
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:20.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.saveNewTaskButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _saveNewTaskButtonLayoutConstraints = @[H1, H2, V1, V2];
}

- (void)prepareCancelNewTaskButtonLayoutsConstraints {
    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.cancelNewTaskButton
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.cancelNewTaskButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:70.0];

    _trailingConstraintForCancelNewTaskButton = H1;
    _widthConstraintForCancelNewTaskButton = H2;

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.cancelNewTaskButton
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:20.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.cancelNewTaskButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0];
    _cancelNewTaskButtonLayoutConstraints = @[H1, H2, V1, V2];
}

#pragma mark - Animations

-(void)animateNewTaskButton:(void (^)(void)) completion{
    if(!self.theNewTaskButton){
        [self showNewTaskButton];
    }

    [_widthConstraintForNewTaskButton setConstant:70];
    [self layoutSubviews];
    [UIView animateWithDuration:0.5 animations:^{
        [_widthConstraintForNewTaskButton setConstant:110];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [_widthConstraintForNewTaskButton setConstant:50];
            [self layoutSubviews];
        } completion:^(BOOL finished1) {
            [UIView animateWithDuration:0.5 animations:^{
                [_widthConstraintForNewTaskButton setConstant:90];
                [self layoutSubviews];
            } completion:^(BOOL finished2) {
                [UIView animateWithDuration:0.5 animations:^{
                    [_widthConstraintForNewTaskButton setConstant:70];
                    [self layoutSubviews];
                } completion:^(BOOL finished3) {
                    [_widthConstraintForNewTaskButton setConstant:70];
                    if(completion){
                        completion();
                    }
                }];
            }];
        }];
    }];
}

@end