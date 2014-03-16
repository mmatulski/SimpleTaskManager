//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserActionsHelperView;


@interface DragAndDropHandler : NSObject

@property(nonatomic, strong) UIView * draggingSpace;
@property(nonatomic, strong) UIImageView *draggedView;

- (instancetype)initWithDraggingSpace:(UIView *)draggingSpace;


- (void)dragView:(UIView *)viewToDrag fromPoint:(CGPoint)point;

- (void)moveDraggedViewToPoint:(CGPoint)point;

- (void)stopDragging;
@end