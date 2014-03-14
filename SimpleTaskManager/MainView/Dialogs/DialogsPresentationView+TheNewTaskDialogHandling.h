//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogsPresentationView.h"

@interface DialogsPresentationView (TheNewTaskDialogHandling)

- (void)userStartsOpeningTheNewTaskDialog;

- (void)userMovesTheNewTaskDialogByX:(CGFloat)x;

- (void)userEndsMovingDialogWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity;

- (void)userCancelsMovingTheNewTaskDialog;
@end