//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserActionsHelperView.h"

@class STMTask;

@interface UserActionsHelperView (TaskOptions)

- (void)showTaskOptionsViewForTask:(STMTask *)task representedByCell:(UITableViewCell *)cell;

- (void)closeTaskOptions;

- (void)updateTaskOptionsForTaskBecauseItWasScrolledBy:(CGFloat)change;

- (BOOL)isShowingTaskOptionsView;
@end