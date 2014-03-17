//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "UserActionsHelperView+TheNewTaskDialogHandling.h"
#import "MainViewConsts.h"
#import "TheNewTaskDialog.h"
#import "CGEstimations.h"
#import "STMTask.h"
#import "DBAccess.h"
#import "DBController.h"
#import "UserActionsHelperView+Hints.h"
#import "ConfirmationHintView.h"
#import "CancelHintView.h"
#import "UserActionsHelperViewDelegate.h"

@implementation UserActionsHelperView (TheNewTaskDialogHandling)

- (void)prepareTheNewTaskDialogLayoutConstraints {

    [self.theNewTaskDialog setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint * H1WhenShown = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0];

    NSLayoutConstraint *H1WhenHiddenBehindRightEdge = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0];

    NSLayoutConstraint *H1WhenHiddenBehindLeftEdge = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeLeading
                                                                                  multiplier:1.0
                                                                                    constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.theNewTaskDialog
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
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
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0];

    self.theNewTaskDialogLayoutConstraintsWhenOpened = @[H1WhenShown, H2, V1, V2];
    self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge = @[H1WhenHiddenBehindRightEdge, H2, V1, V2];
    self.theNewTaskDialogLayoutConstraintsWhenBehindTheLeftEdge = @[H1WhenHiddenBehindLeftEdge, H2, V1, V2];
}

- (void)userStartsOpeningTheNewTaskDialog {
    [self prepareTheNewTaskDialog];
    [self moveTheNewTaskDialogBehindTheRightEdge];

    _originalPositionOfTheNewTaskDialogBeforeMoving = self.theNewTaskDialog.center;
    self.state = DPStateNewTaskDialogOpeningStarted;
}

- (void)prepareTheNewTaskDialog {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;

    self.theNewTaskDialog = [[TheNewTaskDialog alloc] initWithFrame:CGRectMake(0, 44, 100, 100)];
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

- (void)userFinishesOpeningTheNewTaskDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    if([self shouldOpenTheNewTaskDialogForTranslation:translation andVelocity:velocity]){
        CGFloat vectorLength = [CGEstimations pointDistanceToCenterOfAxis:velocity];
        [self animatedMovingTheNewTaskDialogToOpenedStatePosition:vectorLength completion:NULL];

    } else {
        [self animateClosingTheNewTaskDialogToTheRightEdge];
    }
}

- (void)userCancelsMovingTheNewTaskDialog {
    [self animateClosingTheNewTaskDialogToTheRightEdge];
}

- (BOOL)shouldOpenTheNewTaskDialogForTranslation:(CGPoint)translation andVelocity:(CGPoint)velocity {

    //if velocity is greater than zero it means the direction in to right edge
    // 10.0 is the value which is safe to eliminate the case when UserSide stops moving his finger
    if(velocity.x > 10.0){
        return false;
    }

    //if UserSide will not
    if(translation.x > -40.0){
        return false;
    }

    return true;
}

//TODO replace strength with time
- (void)animatedMovingTheNewTaskDialogToOpenedStatePosition:(CGFloat)strength completion:(void (^)(void)) completion {

    self.state = DPStateNewTaskDialogOpeningAnimating;

    CGFloat animationDuration = 1.0f *  500.0 / (strength>0?strength:500.0);

    if(animationDuration > 0.7){
        animationDuration = 0.7;
    }

    self.confirmationHintView.alpha = 0.0;
    self.cancelHintView.alpha = 0.0;

    [UIView animateWithDuration:animationDuration animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self layoutSubviews];

        self.confirmationHintView.alpha = 1.0;
        self.cancelHintView.alpha = 1.0;

    } completion:^(BOOL finished) {
        [self theNewTaskViewNowIsOpenedAndReady];

        if(completion){
            completion();
        }
    }];
}

- (void)theNewTaskViewNowIsOpenedAndReady {
    self.state = DPStateNewTaskDialogOpened;
    [self.theNewTaskDialog setEditing];
    [self moveGestureRecognizerToThewNewTaskDialog];

    [self showConfirmationHint];
    [self showCancelHint];
}

- (void)animateClosingTheNewTaskDialogToTheRightEdge {

    self.state = DPStateNewTaskDialogClosingAnimating;

    [UIView animateWithDuration:0.7 animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
        self.confirmationHintView.alpha = 0.0;
        self.cancelHintView.alpha = 0.0;

        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [self removeTheNewTaskView];
    }];
}

- (void)removeTheNewTaskView {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;
    self.state = DPStateNoOpenedDialogs;

    [self returnGestureRecognizerFromThewNewTaskDialog];

    [self removeConfirmationHintView];
    [self removeCancelHintView];
}

- (void)returnGestureRecognizerFromThewNewTaskDialog {
    [self.theNewTaskDialog removeGestureRecognizer:self.panGestureRecognizer];
    [self addGestureRecognizer:self.panGestureRecognizer];
}

-(void) moveGestureRecognizerToThewNewTaskDialog{
    [self removeGestureRecognizer:self.panGestureRecognizer];
    [self.theNewTaskDialog addGestureRecognizer:self.panGestureRecognizer];
}

- (void)handlePanOnTheNewTaskDialog:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view];
    DDLogTrace(@"handlePanOnTheNewTaskDialog %@", NSStringFromCGPoint(translation));

    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self userStartsClosingTheNewTaskDialog];
    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        [self userMovesTheNewTaskDialogByX:translation.x];
    } else if(recognizer.state == UIGestureRecognizerStateEnded){
        CGPoint velocity = [recognizer velocityInView:self];
        [self userFinishesClosingTheNewTaskDialogWithTranslation:translation velocity:velocity];


    } else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        [self animatedMovingTheNewTaskDialogToOpenedStatePosition:0.0 completion:NULL];
    }
}

- (void)userStartsClosingTheNewTaskDialog {
    _originalPositionOfTheNewTaskDialogBeforeMoving = self.theNewTaskDialog.center;
    self.state = DPStateNewTaskDialogClosingBegan;
}

- (void)userFinishesClosingTheNewTaskDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    if([self shouldCloseAndSaveTheNewTaskDialogForTranslation:translation andVelocity:velocity]){
        [self.delegate userWantsToSaveTheNewTask:[self.theNewTaskDialog taskName]];
    } else if([self shouldCloseAndCancelTheNewTaskDialogForTranslation:translation andVelocity:velocity]){
        [self animateClosingTheNewTaskDialogToTheRightEdge];

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

- (void) theNewTaskSaved {
    [self animateClosingTheNewTaskDialogToTheLeftEdge];
}

- (void)showWarningForTheNewTask:(NSString *)message {
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:self.theNewTaskDialog.frame];
    warningLabel.text = message;
    warningLabel.textColor = [UIColor redColor];
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30.0];
    warningLabel.numberOfLines = 0;
    [self addSubview:warningLabel];
    [UIView animateWithDuration:3.0 animations:^{
        warningLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [warningLabel removeFromSuperview];
    }];
}

- (void)animateClosingTheNewTaskDialogToTheLeftEdge {
    self.state = DPStateNewTaskDialogClosingAnimating;

    [UIView animateWithDuration:0.7 animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheLeftEdge];
        self.confirmationHintView.alpha = 0.0;
        self.cancelHintView.alpha = 0.0;

        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [self removeTheNewTaskView];
    }];
}

- (BOOL)shouldCloseAndCancelTheNewTaskDialogForTranslation:(CGPoint)point andVelocity:(CGPoint)velocity {
    CGPoint currentTheNewTaskDialogPosition = self.theNewTaskDialog.center;
    CGFloat currentViewWidth = self.frame.size.width;
    if(currentViewWidth > 0){
        CGFloat positionFactor = currentTheNewTaskDialogPosition.x / currentViewWidth;
        if(positionFactor > 0.75 && velocity.x > 0.0){
            return true;
        }
    }

    return NO;
}

- (BOOL)shouldCloseAndSaveTheNewTaskDialogForTranslation:(CGPoint)point andVelocity:(CGPoint)velocity {
    if(![self.theNewTaskDialog isNameValid]){
        return false;
    }

    CGPoint currentTheNewTaskDialogPosition = self.theNewTaskDialog.center;
    CGFloat currentViewWidth = self.frame.size.width;
    if(currentViewWidth > 0){
        CGFloat positionFactor = currentTheNewTaskDialogPosition.x / currentViewWidth;
        if(positionFactor < 0.25 && velocity.x < 0.0){
            return true;
        }
    }

    return NO;
}

- (BOOL)canShowTheNewTaskDialog {
    return self.state == DPStateNoOpenedDialogs;
}


@end