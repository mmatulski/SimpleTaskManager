//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "TaskOptionsView.h"
#import "TaskCompleteButton.h"
#import "DeselectTaskButton.h"
#import "TaskOptionsDelegate.h"


@implementation TaskOptionsView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self prepareTaskCompleteButton];
        [self prepareDeselectTaskButton];
    }

    return self;
}

#pragma mark -

- (void)prepareTaskCompleteButton {
    self.completeButton = [[TaskCompleteButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.completeButton.target = self;
    self.completeButton.action = @selector(complete);
    [self addSubview:self.completeButton];
    [self prepareAndAddCompleteButtonConstraints];
}

- (void)prepareDeselectTaskButton {
    self.deselectTaskButton = [[DeselectTaskButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.deselectTaskButton.target = self;
    self.deselectTaskButton.action = @selector(deselect);
    [self addSubview:self.deselectTaskButton];
    [self prepareAndAddDeselectButtonConstraints];
}

#pragma mark - actions

- (void)complete {

}

- (void)deselect {

}

#pragma mark constraints

- (void)prepareAndAddCompleteButtonConstraints {
    [self.completeButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.completeButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:0.5
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.completeButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:0.3
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.completeButton
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.completeButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];

    [self addConstraints:@[H1, H2, V1, V2]];
}

- (void)prepareAndAddDeselectButtonConstraints {
    [self.deselectTaskButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.deselectTaskButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.5
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.deselectTaskButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:0.3
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.deselectTaskButton
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.deselectTaskButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];

    [self addConstraints:@[H1, H2, V1, V2]];
}


- (BOOL) shouldHandleTouchPoint:(CGPoint)point {
    CGRect completeButtonFrame = self.completeButton.frame;
    CGRect deselectButtonFrame = self.deselectTaskButton.frame;

    CGPoint pointLocal = [self convertPoint:point fromView:nil];
    if(CGRectContainsPoint(completeButtonFrame, pointLocal) || CGRectContainsPoint(deselectButtonFrame, pointLocal)){
        return true;
    }

    return false;

}

@end