//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPState.h"

@class TheNewTaskDialog;
@class MiniHintView;
@class TheNewTaskHintView;

/*
This view is parent for Dialogs like TheNewTaskDialog or Checking Task View.
It contains "Add" button and handler pan gesture which allows to pill AdTaskView from the right edge.

 */
@interface DPView : UIView <UIGestureRecognizerDelegate> {

    CGRect _rectangleSensitiveForAddingTask;
    CGPoint _originalPositionOfTheNewTaskDialogBeforeMoving;

    NSLayoutConstraint *_trailingConstraintForNewTaskHintView;
    NSLayoutConstraint *_widthConstraintForNewTaskHintView;
    NSArray *_hintViewForTheNewTaskLayoutConstraints;

}

@property(nonatomic, strong) TheNewTaskDialog *theNewTaskDialog;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property(nonatomic, strong) NSArray *cachedLayoutConstraints;

@property(nonatomic, strong) NSArray *theNewTaskDialogLayoutConstraintsWhenOpened;
@property(nonatomic, strong) NSArray *theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge;
@property(nonatomic, strong) NSArray *theNewTaskDialogLayoutConstraintsWhenBehindTheLeftEdge;

@property(nonatomic) enum DPState state;

@property(nonatomic, strong) TheNewTaskHintView *hintViewForTheNewTask;

- (id)initWithDefaultFrame;

- (void)viewDidAppear;
@end