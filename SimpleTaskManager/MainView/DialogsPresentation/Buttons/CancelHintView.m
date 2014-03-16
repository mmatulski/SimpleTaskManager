//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "CancelHintView.h"


@implementation CancelHintView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.alpha = 0.85;
        [self prepareCancelButton];
    }

    return self;
}

- (void)prepareCancelButton {
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(buttonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];

    [self addLayoutConstraintsForButton];
}

- (void)addLayoutConstraintsForButton {

    [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.cancelButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.cancelButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.cancelButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.cancelButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];

    [self addConstraints:@[H1, H2, V1, V2]];
}

@end