//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationOverlayView.h"

@interface PresentationOverlayView (Buttons)

- (void)showNewTaskButton;

- (void)animateNewTaskButton:(void (^)(void))completion;

- (void)removeSaveNewTaskButton;

- (void)removeCancelTaskButton;

- (void)showSaveNewTaskButton;

- (void)showCancelNewTaskButton;

@end