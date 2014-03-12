//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "WrapperForAddingTaskView.h"


@implementation WrapperForAddingTaskView {

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
    self.backgroundColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.2 alpha:0.5];

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGestureRecognizer];

}

- (void)handlePan:(id)handlePan {
    NSLog(@"handlePan");
}

- (NSArray *)layoutConstraintsForHiddenMode {
    if(!_layoutConstraintsForHiddenMode){
        [self prepareLayoutConstraints];
    }
    
    return _layoutConstraintsForHiddenMode;
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
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:10.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:20.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:-20.0];
    self.layoutConstraintsForHiddenMode = @[H1, H2, V1, V2];
}


@end