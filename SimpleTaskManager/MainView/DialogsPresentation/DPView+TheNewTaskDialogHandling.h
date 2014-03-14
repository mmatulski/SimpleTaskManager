//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPView.h"

@interface DPView (TheNewTaskDialogHandling)

- (void)userStartsOpeningTheNewTaskDialog;

- (void)userMovesTheNewTaskDialogByX:(CGFloat)x;

- (void)userFinishesOpeningTheNewTaskDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity;

- (void)userCancelsMovingTheNewTaskDialog;

- (void)handlePanOnTheNewTaskDialog:(UIPanGestureRecognizer *)recognizer;
@end