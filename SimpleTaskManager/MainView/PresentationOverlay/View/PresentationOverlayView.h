//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationOverlayState.h"

@class TheNewTaskDialog;
@class WrappedButton;
@class TheNewTaskButton;
@class SaveNewTaskButton;
@class CancelButton;
@class TaskOptionsView;
@protocol PresentationOverlayViewDelegate;

/*
This PresentationOverlayView is parent for Dialogs like TheNewTaskDialog or Checking Task View.
It contains "Add" button and handles pan gestures which allows to pill AdTaskView from the right edge.

 */
@interface PresentationOverlayView : UIView <UIGestureRecognizerDelegate>{

    CGRect _rectangleSensitiveForAddingTask;
    CGPoint _originalPositionOfTheNewTaskDialogBeforeMoving;

    NSLayoutConstraint *_trailingConstraintForNewTaskButton;
    NSLayoutConstraint *_widthConstraintForNewTaskButton;
    NSArray *_theNewTaskButtonLayoutConstraints;

    NSLayoutConstraint *_leadingConstraintForSaveNewTaskButton;
    NSLayoutConstraint *_widthConstraintForSaveNewTaskButton;
    NSArray *_saveNewTaskButtonLayoutConstraints;

    NSLayoutConstraint *_trailingConstraintForCancelNewTaskButton;
    NSLayoutConstraint *_widthConstraintForCancelNewTaskButton;
    NSArray *_cancelNewTaskButtonLayoutConstraints;

    NSLayoutConstraint *_taskOptionsTopLayoutConstraint;
    NSLayoutConstraint *_taskOptionsHeightLayoutConstraint;
    NSArray *_taskOptionsLayoutConstraints;

    CGFloat _taskOptionsViewFirstTopY;
}

@property(nonatomic, weak) id <PresentationOverlayViewDelegate> delegate;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property(nonatomic, strong) TheNewTaskDialog *theNewTaskDialog;
@property(nonatomic, strong) TheNewTaskButton *theNewTaskButton;
@property(nonatomic, strong) SaveNewTaskButton *saveNewTaskButton;
@property(nonatomic, strong) CancelButton *cancelNewTaskButton;
@property(nonatomic, strong) TaskOptionsView *taskOptionsView;

@property(nonatomic, strong) NSArray *viewLayoutConstraints;
@property(nonatomic, strong) NSArray *theNewTaskDialogLayoutConstraintsWhenOpened;
@property(nonatomic, strong) NSArray *theNewTaskDialogLayoutConstraintsWhenBehindTheRightEdge;
@property(nonatomic, strong) NSArray *theNewTaskDialogLayoutConstraintsWhenBehindTheLeftEdge;

@property(nonatomic) enum PresentationOverlayState state;

- (id)initWithDefaultFrame;

- (void)viewDidAppear;

@end