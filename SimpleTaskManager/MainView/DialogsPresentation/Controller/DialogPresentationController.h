//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOptionsDelegate.h"

@class DPView;
@class STMTask;

@interface DialogPresentationController : NSObject <TaskOptionsDelegate>

@property(nonatomic, strong) DPView* view;

@property(nonatomic, strong) STMTask *currentTaskWithOptionsShown;

- (instancetype)initWithView:(DPView *)view;


- (void)showOptionsForTask:(STMTask *)task representedByCell:(UITableViewCell *)cell;

- (void)closeTaskOptionsForTask:(STMTask *)task;

- (void)updateTaskOptionsForTask:(STMTask *)task becauseItWasScrolledBy:(CGFloat)offsetChange;
@end