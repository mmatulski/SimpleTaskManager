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
    CGPoint _originalPositionBeforeMoving;
    CGRect _lastAddTaskViewFrameWhenHidden;
    CGRect _lastAddTaskViewFrameWhenShown;
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
        [self showTheNewTaskViewFurtherThanRightEdge];
        _originalPositionBeforeMoving = self.theNewTaskDialog.center;

    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        [self moveAddTaskViewByX:translation.x];
    } else if(recognizer.state == UIGestureRecognizerStateEnded){

        CGPoint velocity = [recognizer velocityInView:self];

        if([self shouldShowTheNewTaskViewForTranslation:translation andVelocity:velocity]){
            CGFloat vectorLength = [CGEstimations pointDistanceCenterOfAxis:velocity];
            [self animateMovingTaskViewWithStrength:vectorLength];

        } else {
            [self hideTheNewTaskViewFurtherThanRightEdge];
        }

    } else if(recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
       [self hideTheNewTaskViewFurtherThanRightEdge];
    }
}

- (BOOL)shouldShowTheNewTaskViewForTranslation:(CGPoint)translation andVelocity:(CGPoint)velocity {

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

- (void)animateMovingTaskViewWithStrength:(CGFloat)strength {

    CGFloat animationDuration = 1.0f *  500.0 / (strength>0?strength:500.0);

    if(animationDuration > 0.7){
        animationDuration = 0.7;
    }

    [UIView animateWithDuration:animationDuration animations:^{
        self.theNewTaskDialog.frame = _lastAddTaskViewFrameWhenShown;
    } completion:^(BOOL finished) {
        [self showTheNewTaskViewInFinalPosition];
    }];
}

- (void)hideTheNewTaskViewFurtherThanRightEdge {
    [UIView animateWithDuration:0.7 animations:^{
        self.theNewTaskDialog.frame = _lastAddTaskViewFrameWhenHidden;
    } completion:^(BOOL finished) {
        [self hideTheNewTaskView];
    }];
}

- (void)hideTheNewTaskView {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;
}

- (void)moveAddTaskViewByX:(CGFloat)x{
    CGPoint changedPosition = _originalPositionBeforeMoving;
    changedPosition.x += x;

    self.theNewTaskDialog.center = changedPosition;
}

- (void)showTheNewTaskViewFurtherThanRightEdge {
    [self.theNewTaskDialog removeFromSuperview];
    self.theNewTaskDialog = nil;
    
    self.theNewTaskDialog = [[AddTaskView alloc] initWithFrame:CGRectMake(0, 44, 100, 100)];
    [self addSubview:self.theNewTaskDialog];
    [self.theNewTaskDialog setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.theNewTaskDialog prepareLayoutConstraints];

    _lastAddTaskViewFrameWhenHidden = [self.theNewTaskDialog estimateFrameWithConstraints:self.theNewTaskDialog.layoutConstraintsWhenHidden];
    _lastAddTaskViewFrameWhenShown = [self.theNewTaskDialog estimateFrameWithConstraints:self.theNewTaskDialog.layoutConstraintsWhenShown];

    self.theNewTaskDialog.frame = _lastAddTaskViewFrameWhenHidden;
}

- (void)showTheNewTaskViewInFinalPosition {
    self.theNewTaskDialog.frame = _lastAddTaskViewFrameWhenShown;

    if(self.theNewTaskDialog.layoutConstraintsWhenShown){
        [self addConstraints:self.theNewTaskDialog.layoutConstraintsWhenShown];
    } else {
        DDLogWarn(@"showTheNewTaskViewInFinalPosition layoutConstraintsWhenShown are nil");
    }


    //[self layoutSubviews];
}

- (NSArray *)cachedLayoutConstraints {
    if(!_cachedLayoutConstraints){
        [self prepareLayoutConstraints];
    }

    return _cachedLayoutConstraints;
}

#pragma mark - UIGestrureRecognizer methods

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    CGPoint point = [touch locationInView:self];
    CGRect rectangleForDetectingAddingTask = [self rectangleForDetectingAddingTask];
    if(CGRectContainsPoint(rectangleForDetectingAddingTask, point)){
        return true;
    }

    return NO;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end