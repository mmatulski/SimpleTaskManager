//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "PresentationOverlayView.h"
#import "PresentationOverlayView+Constraints.h"
#import "WrappedButton.h"
#import "PresentationOverlayView+Buttons.h"
#import "TheNewTaskButton.h"
#import "TaskOptionsView.h"
#import "PresentationOverlayView+TaskOptions.h"
#import "PresentationOverlayView+TheNewTaskDialogHandling.h"
#import "SaveNewTaskButton.h"
#import "CancelNewTaskButton.h"
#import "MainViewConsts.h"
#import "PresentationOverlayViewDelegate.h"
#import "TheNewTaskDialog.h"

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

    [self showNewTaskButton];
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

        [self userStartsOpeningNewTaskDialog];

    } else if(recognizer.state == UIGestureRecognizerStateChanged){

        [self userMovesTheNewTaskDialogByX:translation.x];

    } else if(recognizer.state == UIGestureRecognizerStateEnded){

        CGPoint velocity = [recognizer velocityInView:self];
        [self userFinishesOpeningTheNewTaskDialogWithTranslation:translation velocity:velocity];

    } else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {

        [self userCancelsMovingTheNewTaskDialog];
    }
}

- (NSArray *)viewLayoutConstraints {
    if(!_viewLayoutConstraints){
        [self prepareLayoutConstraints];
    }

    return _viewLayoutConstraints;
}

- (CGRect)rectangleForDetectingNewTaskPan {
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

- (void)setState:(enum PresentationOverlayState)state {
    if(_state != state){
        _state = state;

//        switch (state){
//            case PresentationOverlayStateNewTaskDialogOpened:
//            case PresentationOverlayStateNewTaskDialogOpeningStarted:
//            case PresentationOverlayStateNewTaskDialogOpeningAnimating:
//                [self.theNewTaskDialog setEditing:YES ];
//                break;
//
//            case PresentationOverlayStateNormal:
//            case PresentationOverlayStateNewTaskDialogClosingBegan:
//            case PresentationOverlayStateNewTaskDialogClosingAnimating:
//                [self.theNewTaskDialog setEditing:YES ];
//                break;
//        }

        if(state == PresentationOverlayStateNormal){
            [self.delegate theNewTaskDialogClosed];
        } else {
            [self.delegate theNewTaskDialogOpened];
        }
    }
}

- (void)updateSensitiveViewParts {
    _rectangleSensitiveForAddingTask = CGRectNull;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    if([self isAnyDialogOpenedOrBeganClosing] || [self isAnyDialogAnimatedNow]){
        return [super hitTest:point withEvent:event];
    }

    if([self isTaskOptionsViewShown]){
        CGPoint pointGlobal = [self convertPoint:point toView:nil];
        if([self.taskOptionsView shouldHandleTouchPoint:pointGlobal]){
            return [super hitTest:point withEvent:event];
        }
    }

    CGRect rectangleForDetectingNewTaskPan = [self rectangleForDetectingNewTaskPan];

    if(CGRectContainsPoint(rectangleForDetectingNewTaskPan, point)){
        return [super hitTest:point withEvent:event];
    }

    CGRect rectangleForTheNewTaskButton = self.theNewTaskButton.frame;
    if(CGRectContainsPoint(rectangleForTheNewTaskButton, point)){
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
        if(self.saveNewTaskButton && self.saveNewTaskButton.superview){
            CGRect rectangleForConfirmHintView = self.saveNewTaskButton.frame;
            if(CGRectContainsPoint(rectangleForConfirmHintView, point)){
                return false;
            }
        }

        if(self.cancelNewTaskButton && self.cancelNewTaskButton.superview){
            CGRect rectangleForCancelHintView = self.cancelNewTaskButton.frame;
            if(CGRectContainsPoint(rectangleForCancelHintView, point)){
                return false;
            }
        }

        if([gestureRecognizer.view isEqual:self.theNewTaskDialog]){
            return true;
        }
    }

    CGRect rectangleForDetectingNewTaskPan = [self rectangleForDetectingNewTaskPan];
    if(CGRectContainsPoint(rectangleForDetectingNewTaskPan, point)){
        return true;
    }

    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear {
    [self animateNewTaskButton:^{

    }];
}

@end