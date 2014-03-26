//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView+TheNewTaskDialogHandling.h"
#import "MainViewConsts.h"
#import "TheNewTaskDialog.h"
#import "CGEstimations.h"
#import "PresentationOverlayView+Buttons.h"
#import "SaveNewTaskButton.h"
#import "CancelNewTaskButton.h"
#import "PresentationOverlayViewDelegate.h"

@implementation PresentationOverlayView (TheNewTaskDialogHandling)

#pragma mark - layout constraints

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



- (void)userStartsOpeningNewTaskDialog {
    [self prepareTheNewTaskDialog];
    [self moveTheNewTaskDialogBehindTheRightEdge];

    _originalPositionOfTheNewTaskDialogBeforeMoving = self.theNewTaskDialog.center;
    self.state = PresentationOverlayStateNewTaskDialogOpeningStarted;
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
        [self animatedMovingNewTaskDialogToOpenedStatePosition:vectorLength completion:NULL];

    } else {
        [self animateClosingTheNewTaskDialogToTheRightEdge];
    }
}

- (void)userCancelsMovingTheNewTaskDialog {
    [self animateClosingTheNewTaskDialogToTheRightEdge];
}

- (BOOL)shouldOpenTheNewTaskDialogForTranslation:(CGPoint)translation andVelocity:(CGPoint)velocity {

    //if velocity is greater than zero it means the direction in to right edge
    // 10.0 is the value which is safe to eliminate the case when LocalUserLeg stops moving his finger
    if(velocity.x > 10.0){
        return false;
    }

    //if LocalUserLeg will not
    if(translation.x > -40.0){
        return false;
    }

    return true;
}

//TODO replace strength with time
- (void)animatedMovingNewTaskDialogToOpenedStatePosition:(CGFloat)strength completion:(void (^)(void)) completion {

    self.state = PresentationOverlayStateNewTaskDialogOpeningAnimating;

    CGFloat animationDuration = 1.0f *  500.0 / (strength>0?strength:500.0);

    if(animationDuration > 0.7){
        animationDuration = 0.7;
    }

    self.saveNewTaskButton.alpha = 0.0;
    self.cancelNewTaskButton.alpha = 0.0;

    [UIView animateWithDuration:animationDuration animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self layoutSubviews];

        self.saveNewTaskButton.alpha = 1.0;
        self.cancelNewTaskButton.alpha = 1.0;

    } completion:^(BOOL finished) {
        [self theNewTaskViewNowIsOpenedAndReady];

        if(completion){
            completion();
        }
    }];
}

- (void)theNewTaskViewNowIsOpenedAndReady {
    self.state = PresentationOverlayStateNewTaskDialogOpened;
    [self.theNewTaskDialog setEditing:YES ];
    [self moveGestureRecognizerToThewNewTaskDialog];

    [self showSaveNewTaskButton];
    [self showCancelNewTaskButton];
}

- (void)animateClosingTheNewTaskDialogToTheRightEdge {

    self.state = PresentationOverlayStateNewTaskDialogClosingAnimating;

    [UIView animateWithDuration:0.7 animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge];
        self.saveNewTaskButton.alpha = 0.0;
        self.cancelNewTaskButton.alpha = 0.0;

        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [self removeTheNewTaskView];
    }];
}

- (void)removeTheNewTaskView {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;
    self.state = PresentationOverlayStateNormal;

    [self returnGestureRecognizerFromThewNewTaskDialog];

    [self removeSaveNewTaskButton];
    [self removeCancelTaskButton];
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
        [self animatedMovingNewTaskDialogToOpenedStatePosition:0.0 completion:NULL];
    }
}

- (void)userStartsClosingTheNewTaskDialog {
    _originalPositionOfTheNewTaskDialogBeforeMoving = self.theNewTaskDialog.center;
    self.state = PresentationOverlayStateNewTaskDialogClosingBegan;
}

- (void)userFinishesClosingTheNewTaskDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    if([self shouldCloseAndCancelTheNewTaskDialogForTranslation:translation andVelocity:velocity]){
        [self animateClosingTheNewTaskDialogToTheRightEdge];
    } else if([self shouldCloseAndSaveTheNewTaskDialogForTranslation:translation andVelocity:velocity]){

        if([self.theNewTaskDialog isNameValid]){
            [self.theNewTaskDialog setEditing:NO];
            [self.delegate userWantsToSaveTheNewTask:[self.theNewTaskDialog taskName]];
        } else {
            NSString *warningMessage = nil;
            if(![self.theNewTaskDialog isNameValid]){
                warningMessage = @"The task can not be empty";
            }

            [self animatedMovingNewTaskDialogToOpenedStatePosition:0.0 completion:^{
                [self showWarningForTheNewTask:warningMessage];
            }];
        }
    } else {
        [self animatedMovingNewTaskDialogToOpenedStatePosition:0.0 completion:^{

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
    self.state = PresentationOverlayStateNewTaskDialogClosingAnimating;

    [UIView animateWithDuration:0.7 animations:^{
        [self removeConstraints:self.theNewTaskDialogLayoutConstraintsWhenOpened];
        [self addConstraints:self.theNewTaskDialogLayoutConstraintsWhenBehindTheLeftEdge];
        self.saveNewTaskButton.alpha = 0.0;
        self.cancelNewTaskButton.alpha = 0.0;

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

- (BOOL)canShowNewTaskDialog {
    return self.state == PresentationOverlayStateNormal;
}

- (void)animateNewTaskViewBackToOpenedPositionWithWarning {
    NSString *warningMessage = nil;
    if (![self.theNewTaskDialog isNameValid]) {
        warningMessage = @"The task can not be empty";
    }

    [self animatedMovingNewTaskDialogToOpenedStatePosition:0.0 completion:^{
        [self showWarningForTheNewTask:warningMessage];
    }];
}

@end