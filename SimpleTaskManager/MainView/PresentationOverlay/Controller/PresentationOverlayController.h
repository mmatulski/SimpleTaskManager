//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOptionsDelegate.h"
#import "PresentationOverlayViewDelegate.h"

@class PresentationOverlayView;
@class STMTask;
@protocol PresentationOverlayControllerDelegate;
@class STMTaskModel;

@interface PresentationOverlayController : NSObject <TaskOptionsDelegate, PresentationOverlayViewDelegate>

@property(nonatomic, weak) id <PresentationOverlayControllerDelegate> delegate;
@property(nonatomic, strong) PresentationOverlayView *presentationOverlayView;
//@property(nonatomic, strong) STMTaskModel *currentTaskWithOptionsShown;

- (instancetype)initWithView:(PresentationOverlayView *)view;

//- (void)showOptionsForTaskModel:(STMTaskModel *)taskModel representedByCell:(UITableViewCell *)cell animated:(BOOL)animated;
//- (void)closeTaskOptionsForTaskModel:(STMTaskModel *)taskModel;
//- (void)updateTaskOptionsForTaskModel:(STMTaskModel *)taskModel becauseItWasScrolledBy:(CGFloat)offsetChange;



#pragma mark - Task Options

- (void)showTaskOptionsForCellWithFrame:(CGRect) cellFrame animated:(BOOL)animated;

- (void)updateOptionsViewFrameForCellWithFrame:(CGRect)rect animated:(BOOL)animated;

- (void)closeTaskOptionsAnimated:(BOOL) animated;

- (void)theNewTaskSaved;
@end