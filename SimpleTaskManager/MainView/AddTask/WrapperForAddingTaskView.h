//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
This view is just wrapper for final AddTaskView.
It contains "Add" button and handler pan gesture which allows to pill AdTaskView from the right edge.

 */
@interface WrapperForAddingTaskView : UIView

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, strong) NSArray * layoutConstraintsForHiddenMode;
@property(nonatomic, strong) NSArray * layoutConstraintsForShownMode;

- (id)initWithDefaultFrame;

@end