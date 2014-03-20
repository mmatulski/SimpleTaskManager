//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CompleteTaskButton;
@class DeselectTaskButton;
@protocol TaskOptionsDelegate;


@interface TaskOptionsView : UIView

@property(nonatomic, weak) id <TaskOptionsDelegate> delegate;
@property(nonatomic, strong) CompleteTaskButton *completeButton;
@property(nonatomic, strong) DeselectTaskButton *deselectTaskButton;

- (BOOL) shouldHandleTouchPoint:(CGPoint)point;

@end