//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView.h"
#import "PresentationOverlayView+Constraints.h"
#import "WrappedButton.h"
#import "PresentationOverlayView+Hints.h"
#import "TheNewTaskButton.h"
#import "TaskOptionsView.h"
#import "PresentationOverlayView+TaskOptions.h"
#import "PresentationOverlayView+TheNewTaskDialogHandling.h"
#import "ConfirmationButton.h"
#import "CancelButton.h"

CGFloat const kRightMarginForHandlingPanGesture = 20.0;

@implementation PresentationOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }

    return self;
}


- (id)initWithDefaultFrame {
    CGRect defaultFrame = CGRectZero;
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

    [self showOpeningTheNewTaskViewHint];
}

- (void)didRotate {
    [self updateSensitiveViewParts];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    if([recognizer.view isEqual:self.theNewTaskDialog]){
        [self handlePanOnTheNewTaskDialog:recognizer];
        return;
    }

    CGPoint translation = [recognizer translationInView:recognizer.view];

    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self userStartsOpeningTheNewTaskDialog];
    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        [self userMovesTheNewTaskDialogByX:translation.x];
    } else if(recognizer.state == UIGestureRecognizerStateEnded){

        CGPoint velocity = [recognizer velocityInView:self];

        [self userFinishesOpeningTheNewTaskDialogWithTranslation:translation velocity:velocity];

    } else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        [self userCancelsMovingTheNewTaskDialog];
    }
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

    if([self isAnyDialogOpenedOrBeganClosing]){
        return [super hitTest:point withEvent:event];
    }

    if([self isAnyDialogAnimatedNow]){
        return nil;
    }

    if([self isShowingTaskOptionsView]){
        CGPoint pointGlobal = [self convertPoint:point toView:nil];
        if([self.taskOptionsView shouldHandleTouchPoint:pointGlobal]){
            return [super hitTest:point withEvent:event];
        }
    }

    CGRect rectangleForDetectingAddingTask = [self rectangleForDetectingAddingTask];

    if(CGRectContainsPoint(rectangleForDetectingAddingTask, point)){
        return [super hitTest:point withEvent:event];
    }

    CGRect rectangleForTheNewTaskHintView = self.hintViewForTheNewTask.frame;
    if(CGRectContainsPoint(rectangleForTheNewTaskHintView, point)){
        return [super hitTest:point withEvent:event];
    }

    return nil;
}

- (BOOL)isAnyDialogOpenedOrBeganClosing {
    switch (self.state) {
        case PresentationOverlayStateNewTaskDialogOpened:
        case PresentationOverlayStateNewTaskDialogClosingBegan:
            return true;
        default:
            return false;

    }
}

- (BOOL)isAnyDialogAnimatedNow {
    switch (self.state) {
        case PresentationOverlayStateNewTaskDialogOpeningAnimating:
        case PresentationOverlayStateNewTaskDialogClosingAnimating:
            return true;
        default:
            return false;

    }
}

#pragma mark - UIGestrureRecognizer methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    DDLogTrace(@"gestureRecognizer");

    if([self isAnyDialogAnimatedNow]){
        return false;
    }

    CGPoint point = [touch locationInView:self];

    if([self isAnyDialogOpenedOrBeganClosing]){
        if(self.confirmationHintView && self.confirmationHintView.superview){
            CGRect rectangleForConfirmHintView = self.confirmationHintView.frame;
            if(CGRectContainsPoint(rectangleForConfirmHintView, point)){
                return false;
            }
        }

        if(self.cancelHintView && self.cancelHintView.superview){
            CGRect rectangleForCancelHintView = self.cancelHintView.frame;
            if(CGRectContainsPoint(rectangleForCancelHintView, point)){
                return false;
            }
        }

        if([gestureRecognizer.view isEqual:self.theNewTaskDialog]){
            return true;
        }
    }

    CGRect rectangleForDetectingAddingTask = [self rectangleForDetectingAddingTask];
    if(CGRectContainsPoint(rectangleForDetectingAddingTask, point)){
        return true;
    }

    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear {
    [self animatedHintViewForTheNewTaskView:^{

    }];
}



@end