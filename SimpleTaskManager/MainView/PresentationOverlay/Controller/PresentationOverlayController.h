//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskOptionsDelegate.h"
#import "PresentationOverlayViewDelegate.h"

@class PresentationOverlayView;
@class STMTask;
@class STMTaskModel;
@protocol PresentationOverlayControllerDelegate;

@interface PresentationOverlayController : NSObject <TaskOptionsDelegate, PresentationOverlayViewDelegate>

@property(nonatomic, weak) id <PresentationOverlayControllerDelegate> delegate;
@property(nonatomic, strong) PresentationOverlayView *presentationOverlayView;

- (instancetype)initWithView:(PresentationOverlayView *)view;

#pragma mark - Task Options

- (void)showTaskOptionsForCellWithFrame:(CGRect) cellFrame animated:(BOOL)animated;

- (void)updateOptionsViewFrameForCellWithFrame:(CGRect)rect animated:(BOOL)animated;

- (void)closeTaskOptionsAnimated:(BOOL) animated;

- (void)theNewTaskSaved;

@end