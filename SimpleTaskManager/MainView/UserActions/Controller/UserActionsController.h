//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOptionsDelegate.h"
#import "UserActionsHelperViewDelegate.h"

@class UserActionsHelperView;
@class STMTask;

@interface UserActionsController : NSObject <TaskOptionsDelegate, UserActionsHelperViewDelegate>

@property(nonatomic, strong) UserActionsHelperView *helperView;
@property(nonatomic, strong) STMTask *currentTaskWithOptionsShown;

- (instancetype)initWithView:(UserActionsHelperView *)view;

- (void)showOptionsForTask:(STMTask *)task representedByCell:(UITableViewCell *)cell;
- (void)closeTaskOptionsForTask:(STMTask *)task;
- (void)updateTaskOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)offsetChange;

@end