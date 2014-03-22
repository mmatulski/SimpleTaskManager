//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DeselectTaskButton.h"
#import "AppColors.h"


@implementation DeselectTaskButton {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [AppColors stillToDoButtonColor];
        self.alpha = 0.85;
        [self prepareButton];
    }

    return self;
}

- (void)prepareButton {
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"Still to do" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];

    [self addLayoutConstraintsForButton];
}

- (void)addLayoutConstraintsForButton {

    [self.button setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.button
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.button
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.button
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeBottom
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