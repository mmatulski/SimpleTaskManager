//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DialogsPresentationView.h"

unsigned int const kRightMarginForHandlingPanGesture = 10.0;

@implementation DialogsPresentationView {

    CGRect _rectangleSensitiveForAddingTask;
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
    NSLog(@"handlePan %@", NSStringFromCGPoint(translation));


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
    NSLog(@"point %f %f", point.x, point.y);
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


@end