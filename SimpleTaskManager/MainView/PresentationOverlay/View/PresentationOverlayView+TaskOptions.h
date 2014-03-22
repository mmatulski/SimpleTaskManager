//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationOverlayView.h"

@class STMTask;
@class STMTaskModel;

@interface PresentationOverlayView (TaskOptions)

- (void)showTaskOptionsViewForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell;

- (void)closeTaskOptions;

- (void)updateTaskOptionsForTaskBecauseItWasScrolledBy:(CGFloat)change;

- (BOOL)isShowingTaskOptionsView;
@end