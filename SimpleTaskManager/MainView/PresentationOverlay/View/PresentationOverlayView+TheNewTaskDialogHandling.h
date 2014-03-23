//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationOverlayView.h"

@interface PresentationOverlayView (TheNewTaskDialogHandling)

- (void)userStartsOpeningNewTaskDialog;

- (void)userMovesTheNewTaskDialogByX:(CGFloat)x;

- (void)userFinishesOpeningTheNewTaskDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity;

- (void)userCancelsMovingTheNewTaskDialog;

- (void)animatedMovingNewTaskDialogToOpenedStatePosition:(CGFloat)strength completion:(void (^)(void))completion;

- (void)animateClosingTheNewTaskDialogToTheRightEdge;

- (void)handlePanOnTheNewTaskDialog:(UIPanGestureRecognizer *)recognizer;

- (void)theNewTaskSaved;

- (void)showWarningForTheNewTask:(NSString *)message;

- (BOOL)canShowNewTaskDialog;

- (void)animateNewTaskViewBackToOpenedPositionWithWarning;
@end