//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOptionsDelegate.h"
#import "UserActionsHelperViewDelegate.h"

@class UserActionsHelperView;
@class STMTask;
@protocol UserActionsHelperControllerDelegate;
@class STMTaskModel;

@interface UserActionsController : NSObject <TaskOptionsDelegate, UserActionsHelperViewDelegate>

@property(nonatomic, weak) id <UserActionsHelperControllerDelegate> delegate;
@property(nonatomic, strong) UserActionsHelperView *helperView;
@property(nonatomic, strong) STMTaskModel *currentTaskWithOptionsShown;

- (instancetype)initWithView:(UserActionsHelperView *)view;

- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell;
- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel;
- (void)updateTaskOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)offsetChange;

@end