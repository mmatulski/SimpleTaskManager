//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogsPresentationView.h"
#import "AddTaskView.h"
#import "DialogsPresentationView+Constraints.h"
#import "AddTaskView+Constraints.h"
#import "UIView+LayoutConstraints.h"

CGFloat const kRightMarginForHandlingPanGesture = 10.0;

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


    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self showTaskView];
        _originalPositionBeforeMoving = self.addTaskView.center;

    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        //[self moveAddTaskViewByX:translation.x andByY:translation.y];
    } else if(recognizer.state == UIGestureRecognizerStateEnded){
//        CGPoint velocity = [recognizer velocityInView:self];
//
//        DDLogInfo(@"translation %@ %@", NSStringFromCGPoint(translation), NSStringFromCGPoint(velocity));
//
//        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//        bounceAnimation.removedOnCompletion = NO;
//
//        CGFloat animationDuration = 1.5f;
//
//
//        // Create the path for the bounces.
//        UIBezierPath *bouncePath = [[UIBezierPath alloc] init];
//
//        CGPoint centerPoint = self.center;
//        CGFloat midX = centerPoint.x;
//        CGFloat midY = centerPoint.y;
//
//        CGPoint startPoint = self.addTaskView.center;
//
////        CGFloat originalOffsetX = self.addTaskView.center.x - midX;
////        CGFloat originalOffsetY = self.addTaskView.center.y - midY;
////        CGFloat offsetDivider = 4.0f;
////
////        BOOL stopBouncing = NO;
//
//        // Start the path at the placard's current location.
////        [bouncePath moveToPoint:CGPointMake(self.center.x, self.center.y)];
////        [bouncePath addLineToPoint:CGPointMake(midX, midY)];
//
//        [bouncePath moveToPoint:startPoint];
//
//        [bouncePath addLineToPoint:centerPoint];
//
////        // Add to the bounce path in decreasing excursions from the center.
////        while (stopBouncing != YES) {
////
////            CGPoint excursion = CGPointMake(midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
////            [bouncePath addLineToPoint:excursion];
////            [bouncePath addLineToPoint:centerPoint];
////
////            offsetDivider += 4;
////            animationDuration += 1/offsetDivider;
////            if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
////                stopBouncing = YES;
////            }
////        }
//
//        bounceAnimation.path = [bouncePath CGPath];
//        bounceAnimation.duration = animationDuration;
//
//        // Create a basic animation to restore the size of the placard.
//        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//        transformAnimation.removedOnCompletion = YES;
//        transformAnimation.duration = animationDuration;
//        transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//
//
//        // Create an animation group to combine the keyframe and basic animations.
//        CAAnimationGroup *theGroup = [CAAnimationGroup animation];
//
//        // Set self as the delegate to allow for a callback to reenable user interaction.
//        theGroup.delegate = self;
//        theGroup.duration = animationDuration;
//        theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//
//        theGroup.animations = @[bounceAnimation, transformAnimation];
//
//
//        // Add the animation group to the layer.
//        [self.addTaskView.layer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
    }
}

- (void)moveAddTaskViewByX:(CGFloat)x andByY:(CGFloat)y {
    CGPoint changedPosition = _originalPositionBeforeMoving;
    changedPosition.x += x;

    self.addTaskView.center = changedPosition;
}

- (BOOL)isAddTaskViewAlreadyAdded {
    return self.addTaskView && self.addTaskView.superview;
}

- (void)showTaskView {
    [self.addTaskView removeFromSuperview];
    self.addTaskView = nil;
    
    self.addTaskView = [[AddTaskView alloc] initWithFrame:CGRectMake(0, 44, 100, 100)];
    [self addSubview:self.addTaskView];
    [self.addTaskView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.addTaskView prepareLayoutConstraints];

    CGRect frameWhenHidden = [self.addTaskView estimateFrameWithConstraints:self.addTaskView.layoutConstraintsWhenHidden];
    CGRect frameWhenShown = [self.addTaskView estimateFrameWithConstraints:self.addTaskView.layoutConstraintsWhenShown];

    DDLogInfo(@"estimated frames %@ %@", NSStringFromCGRect(frameWhenHidden), NSStringFromCGRect(frameWhenShown));

    self.addTaskView.frame = frameWhenShown;
}

- (void)moveAddTaskViewOutOfTheRightEdge {
    [self.addTaskView prepareLayoutConstraints];

    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:self.addTaskView.layoutConstraintsWhenShown];
}

- (NSArray *)layoutConstraints {
    if(!_layoutConstraints){
        [self prepareLayoutConstraints];
    }

    return _layoutConstraints;
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