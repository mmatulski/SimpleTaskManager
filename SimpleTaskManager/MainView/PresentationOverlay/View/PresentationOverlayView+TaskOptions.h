//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationOverlayView.h"

@class STMTask;
@class STMTaskModel;

@interface PresentationOverlayView (TaskOptions)

- (BOOL)isTaskOptionsViewShown;

- (void)showTaskOptionsForCellWithFrame:(CGRect)rect animated:(BOOL)animated;

- (void)closeTaskOptionsAnimated:(BOOL)animated;

//- (void)updateTaskOptionsForTaskBecauseItWasScrolledBy:(CGFloat)change;
//




@end