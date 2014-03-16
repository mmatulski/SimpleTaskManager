//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserActionsHelperView.h"

@interface UserActionsHelperView (TheNewTaskDialogHandling)

- (void)userStartsOpeningTheNewTaskDialog;

- (void)userMovesTheNewTaskDialogByX:(CGFloat)x;

- (void)userFinishesOpeningTheNewTaskDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity;

- (void)userCancelsMovingTheNewTaskDialog;

- (void)animatedMovingTheNewTaskDialogToOpenedStatePosition:(CGFloat)strength completion:(void (^)(void))completion;

- (void)animateClosingTheNewTaskDialogToTheRightEdge;

- (void)handlePanOnTheNewTaskDialog:(UIPanGestureRecognizer *)recognizer;

- (void)addingTaskComfirmed;

- (void)showWarningForTheNewTask:(NSString *)message;

- (BOOL)canShowTheNewTaskDialog;
@end