//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddTaskView;

/*
This view is parent for Dialogs like AddTaskView or Checking Task View.
It contains "Add" button and handler pan gesture which allows to pill AdTaskView from the right edge.

 */
@interface DialogsPresentationView : UIView <UIGestureRecognizerDelegate>

@property(nonatomic, strong) AddTaskView *theNewTaskDialog;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, strong) NSArray *cachedLayoutConstraints;

- (id)initWithDefaultFrame;

@end