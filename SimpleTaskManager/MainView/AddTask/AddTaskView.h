//
// Created by Marek M on 11.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AddTaskView : UIView


@property(nonatomic, strong) CAGradientLayer *bgLayer;

@property(nonatomic, strong) NSArray *layoutConstraintsWhenShown;
@property(nonatomic, strong) NSArray *layoutConstraintsWhenHidden;
@end