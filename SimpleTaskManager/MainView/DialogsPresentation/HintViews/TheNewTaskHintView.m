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
    self.addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.addButton addTarget:self action:@selector(addButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];

    [self addLayoutConstraintsForAddButton];
}

- (void)addButtonSelected {
    if(self.target && self.action){
        if([self.target respondsToSelector:self.action]){
            [self.target performSelector:self.action];
        }
    }
}

- (void)addLayoutConstraintsForAddButton {

    [self.addButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSLayoutConstraint *H1 = [NSLayoutConstraint constraintWithItem:self.addButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:4.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.addButton
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:40.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.addButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.addButton
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0];

    [self addConstraints:@[H1, H2, V1, V2]];
}

@end