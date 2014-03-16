//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "TheNewTaskHintView.h"


@implementation TheNewTaskHintView {

}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareAddButton];
    }

    return self;
}

- (void)prepareAddButton {
    self.button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.button addTarget:self action:@selector(buttonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];

    [self addLayoutConstraintsForAddButton];
}

- (void)addLayoutConstraintsForAddButton {

    [self.button setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.button
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:4.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.button
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:40.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.button
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.button
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];

    [self addConstraints:@[H1, H2, V1, V2]];
}

@end