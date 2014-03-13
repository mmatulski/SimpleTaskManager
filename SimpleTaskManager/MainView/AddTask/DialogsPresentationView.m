//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogsPresentationView.h"
#import "AddTaskView.h"

unsigned int const kRightMarginForHandlingPanGesture = 10.0;

@implementation DialogsPresentationView {

    CGRect _rectangleSensitiveForAddingTask;
    CGPoint _originalPositionBeforeMoving;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }

    return self;
}


- (id)initWithDefaultFrame {
    CGRect defaultFrame = CGRectMake(0, 0, 20, 300);
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
    [self moveAddTaskViewByX:translation.x andByY:translation.y];
}

- (void)moveAddTaskViewByX:(CGFloat)x andByY:(CGFloat)y {
    if(![self isAddTaskViewAlreadyAdded]){
        [self showTaskView];
        _originalPositionBeforeMoving = self.addTaskView.center;
    }

    CGPoint changedPosition = _originalPositionBeforeMoving;
    changedPosition.x += x;
    changedPosition.y += y;

    NSLog(@"moveAddTaskViewToByX %@ -> %@", NSStringFromCGPoint(_originalPositionBeforeMoving)
    , NSStringFromCGPoint(changedPosition));

    self.addTaskView.center = changedPosition;
}

- (BOOL)isAddTaskViewAlreadyAdded {
    return self.addTaskView && self.addTaskView.superview;
}

- (void)showTaskView {
    [self.addTaskView removeFromSuperview];
    self.addTaskView = nil;
    
    self.addTaskView = [[AddTaskView alloc] initWithFrame:CGRectMake(0, 20, 400, 300)];
    [self moveAddTaskViewOutOfTheRightEdge];
    [self addSubview:self.addTaskView];
}

- (void)moveAddTaskViewOutOfTheRightEdge {
    CGRect currentFrame =  self.addTaskView.frame;
    CGRect changedFrame = currentFrame;
    changedFrame.origin.x = self.bounds.size.width;
    self.addTaskView.frame = changedFrame;
}

- (NSArray *)layoutConstraints {
    if(!_layoutConstraints){
        [self prepareLayoutConstraints];
    }

    return _layoutConstraints;
}

- (void)prepareLayoutConstraints {
    //hidden mode

    [self setTranslatesAutoresizingMaskIntoConstraints:false];
    NSLayoutConstraint * H1 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:00.0];
    self.layoutConstraints = @[H1, H2, V1, V2];
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