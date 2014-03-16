//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskCompleteButton;
@class DeselectTaskButton;


@interface TaskOptionsView : UIView

@property(nonatomic, strong) TaskCompleteButton *completeButton;
@property(nonatomic, strong) DeselectTaskButton *deselectTaskButton;

@end