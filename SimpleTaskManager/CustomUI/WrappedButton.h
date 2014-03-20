//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WrappedButton : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;

- (void)buttonSelected;

@end