//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "ConfirmationHintView.h"


@implementation ConfirmationHintView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        self.alpha = 0.85;
        [self prepareOkButton];
    }

    return self;
}

- (void)prepareOkButton {
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.okButton setTitle:@"OK" forState:UIControlStateNormal];
    [self.okButton addTarget:self action:@selector(buttonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.okButton];

    [self addLayoutConstraintsForButton];
}

- (void)addLayoutConstraintsForButton {

    [self.okButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.okButton
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.okButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.okButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.okButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];

    [self addConstraints:@[H1, H2, V1, V2]];
}

@end