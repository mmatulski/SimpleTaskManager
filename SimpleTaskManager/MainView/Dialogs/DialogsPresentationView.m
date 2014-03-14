//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogsPresentationView.h"
#import "AddTaskView.h"
#import "DialogsPresentationView+Constraints.h"
#import "AddTaskView+Constraints.h"
#import "UIView+LayoutConstraints.h"
#import "CGEstimations.h"

CGFloat const kRightMarginForHandlingPanGesture = 10.0;

@implementation DialogsPresentationView {

    CGRect _rectangleSensitiveForAddingTask;
    CGPoint _originalPositionOfTheNewTaskDialogBeforeMoving;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }

    return self;
}


- (id)initWithDefaultFrame {
    CGRect defaultFrame = CGRectMake(0, 0, 100, 100);
    self = [super initWithFrame:defaultFrame];
    if(self){
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];

}

- (void)didRotate {
    [self updateSensitiveViewParts];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view];

    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self prepareTheNewTaskDialog];
        [self moveTheNewTaskDialogBehindTheRightEdge];
       // [self removeLayoutConstraintsForTheNewTaskDialog];

        _originalPositionOfTheNewTaskDialogBeforeMoving = self.theNewTaskDialog.center;

    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        [self moveTheNewTaskDialogByX:translation.x];
    } else if(recognizer.state == UIGestureRecognizerStateEnded){

        CGPoint velocity = [recognizer velocityInView:self];

        if([self shouldOpenTheNewTaskDialogForTranslation:translation andVelocity:velocity]){
            CGFloat vectorLength = [CGEstimations pointDistanceToCenterOfAxis:velocity];
            [self animatedMovingTheNewTaskDialogToOpenedStatePosition:vectorLength];

        } else {
            [self animatedClosingTheNewTaskDialog];
        }

    } else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        [self animatedClosingTheNewTaskDialog];
    }
}

- (void)prepareTheNewTaskDialog {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;

    self.theNewTaskDialog = [[AddTaskView alloc] initWithFrame:CGRectMake(0, 44, 100, 100)];
    [self addSubview:self.theNewTaskDialog];
    [self.theNewTaskDialog prepareLayoutConstraints];
}

- (void)moveTheNewTaskDialogBehindTheRightEdge {
    [self removeConstraints:self.theNewTaskDialog.theNewTaskDialogLayoutConstraints];
    [self addConstraints:self.theNewTaskDialog.theNewTaskDialogLayoutConstraintsForViewBehindTheRightEdge];
    [self layoutSubviews];
}

- (void)moveTheNewTaskDialogByX:(CGFloat)x{
    CGPoint changedPosition = _originalPositionOfTheNewTaskDialogBeforeMoving;
    changedPosition.x += x;

    self.theNewTaskDialog.center = changedPosition;
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
        [self removeConstraints:self.theNewTaskDialog.theNewTaskDialogLayoutConstraintsForViewBehindTheRightEdge];
        [self addConstraints:self.theNewTaskDialog.theNewTaskDialogLayoutConstraints];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
    }];
}

- (void)animatedClosingTheNewTaskDialog {
    [UIView animateWithDuration:0.7 animations:^{
        [self removeConstraints:self.theNewTaskDialog.theNewTaskDialogLayoutConstraints];
        [self addConstraints:self.theNewTaskDialog.theNewTaskDialogLayoutConstraintsForViewBehindTheRightEdge];
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        [self removeTheNewTaskView];
    }];
}

- (void)removeTheNewTaskView {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;
}

- (NSArray *)cachedLayoutConstraints {
    if(!_cachedLayoutConstraints){
        [self prepareLayoutConstraints];
    }

    return _cachedLayoutConstraints;
}

- (CGRect)rectangleForDetectingAddingTask {
    if(CGRectIsNull(_rectangleSensitiveForAddingTask)){
        CGRect result = self.bounds;
        CGRect temp;
        CGRectDivide(result, &result, &temp, kRightMarginForHandlingPanGesture, CGRectMaxXEdge);
        _rectangleSensitiveForAddingTask = result;
    }

    return _rectangleSensitiveForAddingTask;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateSensitiveViewParts];
}

- (void)updateSensitiveViewParts {
    _rectangleSensitiveForAddingTask = CGRectNull;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rectangleForDetectingAddingTask = [self rectangleForDetectingAddingTask];
    if(CGRectContainsPoint(rectangleForDetectingAddingTask, point)){
        return [super hitTest:point withEvent:event];
    }
    
    return nil;
}

#pragma mark - UIGestrureRecognizer methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    CGPoint point = [touch locationInView:self];
    CGRect rectangleForDetectingAddingTask = [self rectangleForDetectingAddingTask];
    if(CGRectContainsPoint(rectangleForDetectingAddingTask, point)){
        return true;
    }

    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end