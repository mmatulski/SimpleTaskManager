//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOptionsDelegate.h"
#import "PresentationOverlayViewDelegate.h"

@class PresentationOverlayView;
@class STMTask;
@protocol UserActionsHelperControllerDelegate;
@class STMTaskModel;

@interface PresentationOverlayController : NSObject <TaskOptionsDelegate, PresentationOverlayViewDelegate>

@property(nonatomic, weak) id <UserActionsHelperControllerDelegate> delegate;
@property(nonatomic, strong) PresentationOverlayView *presentationOverlayView;
@property(nonatomic, strong) STMTaskModel *currentTaskWithOptionsShown;

- (instancetype)initWithView:(PresentationOverlayView *)view;

- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell animated:(BOOL)animated;
- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel;
- (void)updateTaskOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)offsetChange;

@end